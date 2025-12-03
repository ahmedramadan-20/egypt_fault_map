part of 'my_reports_cubit.dart';

abstract class MyReportsState {}

class MyReportsInitial extends MyReportsState {}

class MyReportsLoading extends MyReportsState {}

class MyReportsLoaded extends MyReportsState {
  final List<FaultModel> faults;
  MyReportsLoaded(this.faults);
}

class MyReportsError extends MyReportsState {
  final String message;
  MyReportsError(this.message);
}
