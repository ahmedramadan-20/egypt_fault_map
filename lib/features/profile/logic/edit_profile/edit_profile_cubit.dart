import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final FirebaseFirestore _firestore;

  EditProfileCubit(this._firestore) : super(EditProfileInitial());

  Future<void> updateProfile({
    required String userId,
    required String name,
    String? phone,
  }) async {
    emit(EditProfileLoading());

    try {
      // Prepare update data
      final Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
      };

      // Update Firestore
      await _firestore.collection('users').doc(userId).update(updateData);

      emit(EditProfileSuccess());
    } on FirebaseException catch (e) {
      emit(EditProfileError('Failed to update profile: ${e.message}'));
    } on DatabaseException catch (e) {
      emit(EditProfileError(e.message));
    } catch (e) {
      emit(EditProfileError('Failed to update profile. Please try again.'));
    }
  }
}
