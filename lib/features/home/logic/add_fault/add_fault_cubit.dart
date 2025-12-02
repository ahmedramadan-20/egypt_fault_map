import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/fault_model.dart';
import '../../data/repos/fault_repository.dart';
import 'add_fault_state.dart';

class AddFaultCubit extends Cubit<AddFaultState> {
  final FaultRepository _faultRepo;
  final FirebaseAuth _firebaseAuth;

  AddFaultCubit(this._faultRepo, this._firebaseAuth) : super(AddFaultInitial());

  LatLng? selectedLocation;

  void selectLocation(LatLng location) {
    selectedLocation = location;
    emit(AddFaultLocationSelected(location));
  }

  Future<void> addFault({
    required String type,
    required String description,
    required String severity,
  }) async {
    if (selectedLocation == null) {
      emit(AddFaultError("Please select a location on the map."));
      return;
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(AddFaultError("User not logged in."));
      return;
    }

    try {
      emit(AddFaultLoading());

      final faultId = const Uuid().v4();

      final fault = FaultModel(
        id: faultId,
        type: type,
        description: description,
        imageUrl: '', // No image support
        location: FaultLocation(
          lat: selectedLocation!.latitude,
          lng: selectedLocation!.longitude,
          address: '', // TODO: Implement geocoding
        ),
        status: 'pending',
        createdBy: user.uid,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        severity: severity,
      );

      await _faultRepo.addFault(fault);

      // Reset state
      selectedLocation = null;

      emit(AddFaultSuccess());
    } catch (e) {
      emit(AddFaultError(e.toString()));
    }
  }
}
