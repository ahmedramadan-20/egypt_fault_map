part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class FaultWithDistance {
  final FaultModel fault;
  final double? distance;
  
  const FaultWithDistance(this.fault, this.distance);
}

class HomeLoaded extends HomeState {
  final List<FaultWithDistance> faultsWithDistance;
  final Set<Marker> markers;
  final Position? userPosition;

  HomeLoaded(this.faultsWithDistance, this.markers, this.userPosition);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
