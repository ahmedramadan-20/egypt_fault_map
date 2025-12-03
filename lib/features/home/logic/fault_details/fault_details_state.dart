import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class FaultDetailsState {}

class FaultDetailsInitial extends FaultDetailsState {}

class FaultDetailsLoading extends FaultDetailsState {}

class FaultDetailsLoaded extends FaultDetailsState {
  final String reporterName;
  final String reporterEmail;
  final String? profileImage;
  final BitmapDescriptor? markerIcon;

  FaultDetailsLoaded({
    required this.reporterName,
    required this.reporterEmail,
    this.profileImage,
    this.markerIcon,
  });
}

class FaultDetailsError extends FaultDetailsState {
  final String message;
  FaultDetailsError(this.message);
}
