import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'fault_details_state.dart';

class FaultDetailsCubit extends Cubit<FaultDetailsState> {
  final FirebaseFirestore _firestore;

  FaultDetailsCubit(this._firestore) : super(FaultDetailsInitial());

  Future<void> loadReporterInfo(String userId) async {
    emit(FaultDetailsLoading());

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final userName = userData?['name'] ?? 'Unknown User';
        final profilePic = userData?['profilePic'];

        // Check if profilePic is a URL (starts with http/https) or asset path
        if (profilePic != null && profilePic.isNotEmpty) {
          final isUrl =
              profilePic.startsWith('http://') ||
              profilePic.startsWith('https://');

          emit(
            FaultDetailsLoaded(
              reporterName: userName,
              profilePicUrl: profilePic,
              isDefaultPic: !isUrl, // If not URL, it's asset path
            ),
          );
        } else {
          // No profile pic at all
          emit(
            FaultDetailsLoaded(
              reporterName: userName,
              profilePicUrl: null,
              isDefaultPic: true,
            ),
          );
        }
      } else {
        emit(
          FaultDetailsLoaded(
            reporterName: 'Unknown User',
            profilePicUrl: null,
            isDefaultPic: true,
          ),
        );
      }
    } catch (e) {
      emit(FaultDetailsError(e.toString()));
      // Fallback to default
      emit(
        FaultDetailsLoaded(
          reporterName: 'Unknown User',
          profilePicUrl: null,
          isDefaultPic: true,
        ),
      );
    }
  }
}
