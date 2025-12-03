import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import 'fault_details_state.dart';

class FaultDetailsCubit extends Cubit<FaultDetailsState> {
  final FirebaseFirestore _firestore;

  FaultDetailsCubit(this._firestore) : super(FaultDetailsInitial());

  Future<void> loadReporterInfo(String userId, String severity) async {
    emit(FaultDetailsLoading());

    try {
      // Load marker and user data in parallel
      final results = await Future.wait([
        _getCustomMarker(severity),
        _firestore.collection('users').doc(userId).get(),
      ]);

      final markerIcon = results[0] as BitmapDescriptor;
      final userDoc = results[1] as DocumentSnapshot;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'Unknown User';
        final userEmail = userData?['email'] ?? '';
        final profileImage = userData?['profileImage'];

        emit(
          FaultDetailsLoaded(
            reporterName: userName,
            reporterEmail: userEmail,
            profileImage: profileImage,
            markerIcon: markerIcon,
          ),
        );
      } else {
        emit(
          FaultDetailsLoaded(
            reporterName: 'Unknown User',
            reporterEmail: '',
            profileImage: null,
            markerIcon: markerIcon,
          ),
        );
      }
    } on DatabaseException catch (e) {
      emit(FaultDetailsError(e.message));
    } on FirebaseException catch (e) {
      emit(FaultDetailsError('Failed to load reporter info: ${e.message}'));
    } catch (e) {
      emit(FaultDetailsError('Failed to load details. Please try again.'));
    }
  }

  Future<BitmapDescriptor> _getCustomMarker(String severity) async {
    String assetPath;
    switch (severity.toLowerCase()) {
      case 'high':
        assetPath = 'assets/images/high_severity_marker.png';
        break;
      case 'medium':
        assetPath = 'assets/images/medium_severity_marker.png';
        break;
      case 'low':
      default:
        assetPath = 'assets/images/low_severity_marker.png';
        break;
    }

    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 40,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }
}
