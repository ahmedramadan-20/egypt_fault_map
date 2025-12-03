import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/helpers/shared_preferences_helper.dart';
import '../../auth/data/models/app_user.dart';
import '../../home/data/repos/fault_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final IFaultRepository _faultRepository;
  final CacheHelper _cacheHelper;

  ProfileCubit(
    this._firebaseAuth,
    this._firestore,
    this._faultRepository,
    this._cacheHelper,
  ) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        emit(ProfileError('User not logged in'));
        return;
      }

      // Load user data, total faults count, and user faults count in parallel
      final results = await Future.wait([
        _firestore.collection('users').doc(currentUser.uid).get(),
        _faultRepository.getTotalFaultsCount(),
        _faultRepository.getUserFaultsCount(currentUser.uid),
      ]);

      final userDoc = results[0] as DocumentSnapshot;
      final totalFaults = results[1] as int;
      final userFaults = results[2] as int;

      if (!userDoc.exists) {
        emit(ProfileError('User profile not found'));
        return;
      }

      final user = AppUser.fromDoc(userDoc);

      emit(ProfileLoaded(
        user: user,
        totalFaults: totalFaults,
        userFaults: userFaults,
      ));
    } on DatabaseException catch (e) {
      emit(ProfileError(e.message));
    } on FirebaseException catch (e) {
      emit(ProfileError('Failed to load profile: ${e.message}'));
    } catch (e) {
      emit(ProfileError('Failed to load profile. Please try again.'));
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _cacheHelper.remove('uid');
    } catch (e) {
      emit(ProfileError('Failed to logout: ${e.toString()}'));
    }
  }
}
