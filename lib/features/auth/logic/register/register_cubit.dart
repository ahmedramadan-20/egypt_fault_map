import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
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
    } on AuthException catch (e) {
      // Handle specific auth error codes
      String message = e.message;
      if (e.code == 'weak-password') {
        message = 'Password is too weak. Use at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please login instead.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address format.';
      }
      emit(RegisterFailure(message: message));
    } on DatabaseException catch (e) {
      emit(RegisterFailure(message: e.message));
    } catch (e) {
      emit(RegisterFailure(message: 'Registration failed. Please try again.'));
    }
  }
}
