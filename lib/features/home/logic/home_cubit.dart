import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/fault_model.dart';
import '../data/repos/fault_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FaultRepository _faultRepo;

  HomeCubit(this._faultRepo) : super(HomeInitial());

  BitmapDescriptor? _lowSeverityIcon;
  BitmapDescriptor? _mediumSeverityIcon;
  BitmapDescriptor? _highSeverityIcon;

  Future<void> loadFaults({Position? userPosition}) async {
    emit(HomeLoading());
    try {
      await _loadCustomMarkers();
      final faults = await _faultRepo.getAllFaults();

      // Calculate distances and sort if user position is available
      if (userPosition != null) {
        faults.sort((a, b) {
          final distanceA = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            a.location.lat,
            a.location.lng,
          );
          final distanceB = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            b.location.lat,
            b.location.lng,
          );
          return distanceA.compareTo(distanceB);
        });
      }

      final markers = _generateMarkers(faults);
      emit(HomeLoaded(faults, markers, userPosition));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _loadCustomMarkers() async {
    if (_lowSeverityIcon != null) return; // Already loaded

    _lowSeverityIcon = await _getBytesFromAsset(
      'assets/images/low_severity_marker.png',
      100,
    );
    _mediumSeverityIcon = await _getBytesFromAsset(
      'assets/images/medium_severity_marker.png',
      100,
    );
    _highSeverityIcon = await _getBytesFromAsset(
      'assets/images/high_severity_marker.png',
      100,
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
    return BitmapDescriptor.fromBytes(bytes);
  }

  Set<Marker> _generateMarkers(List<FaultModel> faults) {
    return faults.map((fault) {
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
  }
}
