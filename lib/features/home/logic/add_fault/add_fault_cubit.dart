import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/fault_model.dart';
import '../../data/repos/fault_repository.dart';
import 'add_fault_state.dart';

class AddFaultCubit extends Cubit<AddFaultState> {
  final IFaultRepository _faultRepo;
  final FirebaseAuth _firebaseAuth;

  AddFaultCubit(this._faultRepo, this._firebaseAuth) : super(const AddFaultInitial());

  void init(LatLng? initialLocation) {
    if (initialLocation != null) {
      emit(AddFaultLocationSelected(initialLocation));
    }
  }

  void selectLocation(LatLng location) {
    emit(AddFaultLocationSelected(location));
  }

  Future<void> addFault({
    required String type,
    required String description,
    required String severity,
  }) async {
    final selectedLocation = state.selectedLocation;
    if (selectedLocation == null) {
      emit(AddFaultError(
        ValidationException.invalidLocation().message,
        selectedLocation: selectedLocation,
      ));
      return;
    }

    // Validate description
    if (description.trim().isEmpty) {
      emit(AddFaultError(
        ValidationException.emptyField('Description').message,
        selectedLocation: selectedLocation,
      ));
      return;
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(AddFaultError(
        "User not logged in. Please log in and try again.",
        selectedLocation: selectedLocation,
      ));
      return;
    }

    try {
      emit(AddFaultLoading(selectedLocation: selectedLocation));

      final faultId = const Uuid().v4();

      final fault = FaultModel(
        id: faultId,
        type: type,
        description: description,
        imageUrl: '', // No image support
        location: FaultLocation(
          lat: selectedLocation.latitude,
          lng: selectedLocation.longitude,
          address: '', // TODO: Implement geocoding
        ),
        status: 'pending',
        createdBy: user.uid,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        severity: severity,
      );

      await _faultRepo.addFault(fault);

      emit(const AddFaultSuccess());
    } on DatabaseException catch (e) {
      emit(AddFaultError(e.message, selectedLocation: selectedLocation));
    } catch (e) {
      emit(AddFaultError(
        'Failed to add fault: ${e.toString()}',
        selectedLocation: selectedLocation,
      ));
    }
  }
}
