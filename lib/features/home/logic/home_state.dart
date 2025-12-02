part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<FaultModel> faults;
  final Set<Marker> markers;
  final Position? userPosition;

  HomeLoaded(this.faults, this.markers, this.userPosition);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
