import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailureState(message: 'No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(
          LoginFailureState(message: 'Wrong password provided for that user.'),
        );
      } else {
        emit(LoginFailureState(message: 'Check your email and password.'));
      }
    } catch (e) {
      emit(LoginFailureState(message: e.toString()));
    }
  }
}
