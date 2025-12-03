import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AddFaultState {
  final LatLng? selectedLocation;
  const AddFaultState({this.selectedLocation});
}

class AddFaultInitial extends AddFaultState {
  const AddFaultInitial() : super(selectedLocation: null);
}

class AddFaultLoading extends AddFaultState {
  const AddFaultLoading({super.selectedLocation});
}

class AddFaultSuccess extends AddFaultState {
  const AddFaultSuccess() : super(selectedLocation: null);
}

class AddFaultError extends AddFaultState {
  final String message;
  const AddFaultError(this.message, {super.selectedLocation});
}

class AddFaultLocationSelected extends AddFaultState {
  const AddFaultLocationSelected(LatLng location) : super(selectedLocation: location);
}
