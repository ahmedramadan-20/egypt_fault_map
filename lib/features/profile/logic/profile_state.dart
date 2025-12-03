part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AppUser user;
  final int totalFaults;
  final int userFaults;

  ProfileLoaded({
    required this.user,
    required this.totalFaults,
    required this.userFaults,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
