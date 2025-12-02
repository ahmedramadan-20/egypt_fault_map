abstract class FaultDetailsState {}

class FaultDetailsInitial extends FaultDetailsState {}

class FaultDetailsLoading extends FaultDetailsState {}

class FaultDetailsLoaded extends FaultDetailsState {
  final String reporterName;
  final String? profilePicUrl;
  final bool isDefaultPic;

  FaultDetailsLoaded({
    required this.reporterName,
    this.profilePicUrl,
    this.isDefaultPic = false,
  });
}

class FaultDetailsError extends FaultDetailsState {
  final String message;
  FaultDetailsError(this.message);
}
