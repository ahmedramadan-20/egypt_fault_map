abstract class LoginState {}

final class LoginInitial extends LoginState {}

// login states
final class LoginLoadingState extends LoginState {}

final class LoginSuccessState extends LoginState {}

final class LoginFailureState extends LoginState {
  final String message;

  LoginFailureState({required this.message});
}
