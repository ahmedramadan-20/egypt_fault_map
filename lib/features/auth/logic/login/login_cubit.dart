import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/repos/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepo;

  LoginCubit(this._authRepo) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    try {
      emit(LoginLoadingState());
      await _authRepo.login(email: email, password: password);
      emit(LoginSuccessState());
    } on AuthException catch (e) {
      // Handle specific auth error codes
      String message = e.message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many login attempts. Please try again later.';
      }
      emit(LoginFailureState(message: message));
    } on DatabaseException catch (e) {
      emit(LoginFailureState(message: e.message));
    } catch (e) {
      emit(LoginFailureState(message: 'Login failed. Please try again.'));
    }
  }
}
