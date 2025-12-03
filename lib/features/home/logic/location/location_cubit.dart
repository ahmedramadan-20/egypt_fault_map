import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  StreamSubscription<Position>? _positionStream;

  LocationCubit() : super(LocationInitial());

  Future<void> getLocation() async {
    emit(LocationLoading());
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          LocationError('Location services are disabled. Please enable them.'),
        );
        return;
      }

      // Request location permission using permission_handler
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
        if (status.isDenied) {
          emit(LocationPermissionDenied());
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        emit(
          LocationError(
            'Location permissions are permanently denied. Please enable them in settings.',
          ),
        );
        return;
      }

      // If we are here, permission is granted
      // Start listening to stream
      _positionStream?.cancel();
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen(
            (position) => emit(LocationSuccess(position)),
            onError: (e) => emit(LocationError(e.toString())),
          );
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}
