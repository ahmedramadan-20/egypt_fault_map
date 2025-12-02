import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AddFaultState {}

class AddFaultInitial extends AddFaultState {}

class AddFaultLoading extends AddFaultState {}

class AddFaultSuccess extends AddFaultState {}

class AddFaultError extends AddFaultState {
  final String message;
  AddFaultError(this.message);
}

class AddFaultLocationSelected extends AddFaultState {
  final LatLng location;
  AddFaultLocationSelected(this.location);
}
