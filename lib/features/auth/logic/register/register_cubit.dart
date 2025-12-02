import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepo;

  RegisterCubit(this._authRepo) : super(RegisterInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(RegisterLoading());

      await _authRepo.signUp(email: email, password: password, name: name);
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(RegisterFailure(message: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(
          RegisterFailure(
            message: 'The account already exists for that email.',
          ),
        );
      } else if (e.code == 'invalid-email') {
        emit(RegisterFailure(message: 'The email address is not valid.'));
      } else {
        emit(RegisterFailure(message: e.message ?? 'An error occurred.'));
      }
    } catch (e) {
      emit(RegisterFailure(message: e.toString()));
    }
  }
}
