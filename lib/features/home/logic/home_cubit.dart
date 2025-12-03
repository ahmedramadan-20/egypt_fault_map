import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/fault_model.dart';
import '../data/repos/fault_repository.dart';

part 'home_state.dart';

// Global logger instance
final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

// Top-level function for compute
List<FaultWithDistance> _calculateDistances(Map<String, dynamic> data) {
  final faults = data['faults'] as List<FaultModel>;
  final userPos = data['pos'] as Position;
  
  final faultsWithDistance = faults.map((fault) {
    final distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      fault.location.lat,
      fault.location.lng,
    );
    return FaultWithDistance(fault, distance);
  }).toList();
  
  // Sort by distance
  faultsWithDistance.sort((a, b) => a.distance!.compareTo(b.distance!));
  return faultsWithDistance;
}

class HomeCubit extends Cubit<HomeState> {
  final IFaultRepository _faultRepo;

  HomeCubit(this._faultRepo) : super(HomeInitial());

  BitmapDescriptor? _lowSeverityIcon;
  BitmapDescriptor? _mediumSeverityIcon;
  BitmapDescriptor? _highSeverityIcon;

  // Cache markers to avoid regeneration
  Set<Marker>? _cachedMarkers;
  String? _lastFaultsHash;

  // Stream subscription for real-time updates
  StreamSubscription<List<FaultModel>>? _faultsSubscription;
  Position? _currentUserPosition;
  bool _isRealTimeEnabled = false;

  /// Load faults once (one-time fetch)
  Future<void> loadFaults({Position? userPosition}) async {
    _logger.d(
      "HomeCubit: loadFaults called. UserPosition: ${userPosition?.latitude}, ${userPosition?.longitude}",
    );
    _currentUserPosition = userPosition;
    emit(HomeLoading());
    try {
      await _loadCustomMarkers();
      final faults = await _faultRepo.getAllFaults();

      // Calculate distances and sort if user position is available
      List<FaultWithDistance> faultsWithDistance;
      if (userPosition != null) {
        _logger.d("HomeCubit: Calculating distances in background...");
        faultsWithDistance = await compute(_calculateDistances, {
          'faults': faults,
          'pos': userPosition,
        });
      } else {
        faultsWithDistance = faults.map((f) => FaultWithDistance(f, null)).toList();
      }

      final markers = _getMarkers(faults);
      _logger.d(
        "HomeCubit: Emitting HomeLoaded with ${faults.length} faults",
      );
      emit(HomeLoaded(faultsWithDistance, markers, userPosition));
    } on DatabaseException catch (e) {
      _logger.e("HomeCubit: Database error loading faults", error: e);
      emit(HomeError(e.message));
    } catch (e, stackTrace) {
      _logger.e("HomeCubit: Error loading faults", error: e, stackTrace: stackTrace);
      emit(HomeError('Failed to load faults. Please try again.'));
    }
  }

  /// Enable real-time updates with stream
  Future<void> enableRealTimeUpdates({Position? userPosition, int limit = 100}) async {
    if (_isRealTimeEnabled) {
      _logger.d("HomeCubit: Real-time updates already enabled");
      return;
    }

    _logger.d("HomeCubit: Enabling real-time updates with limit: $limit");
    _currentUserPosition = userPosition;
    _isRealTimeEnabled = true;

    // Cancel any existing subscription
    await _faultsSubscription?.cancel();

    // Load markers first
    await _loadCustomMarkers();

    // Subscribe to fault stream
    _faultsSubscription = _faultRepo.watchFaults(limit: limit).listen(
      (faults) async {
        _logger.d("HomeCubit: Received ${faults.length} faults from stream");
        await _processFaults(faults, _currentUserPosition);
      },
      onError: (error, stackTrace) {
        _logger.e("HomeCubit: Stream error", error: error, stackTrace: stackTrace);
        if (error is DatabaseException) {
          emit(HomeError(error.message));
        } else {
          emit(HomeError('Real-time updates failed. Please refresh.'));
        }
      },
    );
  }

  /// Disable real-time updates and cancel stream
  Future<void> disableRealTimeUpdates() async {
    if (!_isRealTimeEnabled) {
      return;
    }

    _logger.d("HomeCubit: Disabling real-time updates");
    _isRealTimeEnabled = false;
    await _faultsSubscription?.cancel();
    _faultsSubscription = null;
  }

  /// Update user position for distance recalculation
  Future<void> updateUserPosition(Position position) async {
    _logger.d("HomeCubit: Updating user position for distance recalculation");
    _currentUserPosition = position;

    // Only recalculate if we have loaded faults
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final faults = currentState.faultsWithDistance.map((f) => f.fault).toList();
      
      // Recalculate distances with new position
      _logger.d("HomeCubit: Recalculating distances in background...");
      final faultsWithDistance = await compute(_calculateDistances, {
        'faults': faults,
        'pos': position,
      });

      final markers = _getMarkers(faults);
      emit(HomeLoaded(faultsWithDistance, markers, position));
    }
  }

  /// Process faults (calculate distances, create markers, emit state)
  Future<void> _processFaults(List<FaultModel> faults, Position? userPosition) async {
    try {
      // Calculate distances and sort if user position is available
      List<FaultWithDistance> faultsWithDistance;
      if (userPosition != null) {
        faultsWithDistance = await compute(_calculateDistances, {
          'faults': faults,
          'pos': userPosition,
        });
      } else {
        faultsWithDistance = faults.map((f) => FaultWithDistance(f, null)).toList();
      }

      final markers = _getMarkers(faults);
      emit(HomeLoaded(faultsWithDistance, markers, userPosition));
    } catch (e, stackTrace) {
      _logger.e("HomeCubit: Error processing faults", error: e, stackTrace: stackTrace);
      emit(HomeError('Failed to process faults. Please try again.'));
    }
  }

  Future<void> _loadCustomMarkers() async {
    if (_lowSeverityIcon != null) return; // Already loaded

    _lowSeverityIcon = await _getBytesFromAsset(
      'assets/images/low_severity_marker.png',
      40,
    );
    _mediumSeverityIcon = await _getBytesFromAsset(
      'assets/images/medium_severity_marker.png',
      40,
    );
    _highSeverityIcon = await _getBytesFromAsset(
      'assets/images/high_severity_marker.png',
      40,
    );
  }

  Future<BitmapDescriptor> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }

  @override
  Future<void> close() async {
    _logger.d("HomeCubit: Closing and cleaning up");
    await _faultsSubscription?.cancel();
    _faultsSubscription = null;
    _cachedMarkers?.clear();
    _cachedMarkers = null;
    _isRealTimeEnabled = false;
    return super.close();
  }

  Set<Marker> _getMarkers(List<FaultModel> faults) {
    // Simple hash check: join IDs. For better perf on huge lists, use a better hash.
    final currentHash = faults.map((e) => e.id).join(',');
    if (_cachedMarkers != null && _lastFaultsHash == currentHash) {
      return _cachedMarkers!;
    }

    _lastFaultsHash = currentHash;
    _cachedMarkers = faults.map((fault) {
      BitmapDescriptor icon;
      switch (fault.severity) {
        case 'High':
          icon = _highSeverityIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case 'Medium':
          icon = _mediumSeverityIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case 'Low':
        default:
          icon = _lowSeverityIcon ?? BitmapDescriptor.defaultMarker;
          break;
      }

      return Marker(
        markerId: MarkerId(fault.id),
        position: LatLng(fault.location.lat, fault.location.lng),
        icon: icon,
        infoWindow: InfoWindow(title: fault.type, snippet: fault.description),
      );
    }).toSet();

    return _cachedMarkers!;
  }
}
