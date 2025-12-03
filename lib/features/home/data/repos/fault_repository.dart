import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/fault_model.dart';

abstract class IFaultRepository {
  Future<void> addFault(FaultModel fault);
  Future<List<FaultModel>> getAllFaults();
  Future<List<FaultModel>> getFaults({
    int limit = 50,
    DocumentSnapshot? startAfter,
  });
  Stream<List<FaultModel>> watchFaults({int limit = 50});
  Future<List<FaultModel>> getFaultsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 50,
  });
  Future<List<FaultModel>> getUserFaults(String userId);
  Future<int> getTotalFaultsCount();
  Future<int> getUserFaultsCount(String userId);
}

class FaultRepository implements IFaultRepository {
  final FirebaseFirestore firestore;

  FaultRepository(this.firestore);

  @override
  Future<void> addFault(FaultModel fault) async {
    try {
      await firestore.collection('faults').doc(fault.id).set(fault.toMap());
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to add fault: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to add fault: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<FaultModel>> getAllFaults() async {
    try {
      final snapshot = await firestore
          .collection('faults')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load faults: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load faults: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<FaultModel>> getFaults({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = firestore
          .collection('faults')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load faults: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load faults: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<List<FaultModel>> watchFaults({int limit = 50}) {
    return firestore
        .collection('faults')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList());
  }

  @override
  Future<List<FaultModel>> getFaultsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 50,
  }) async {
    try {
      // Note: For production, consider using GeoFlutterFire or similar package
      // for efficient geospatial queries. This is a simple implementation.
      final snapshot = await firestore
          .collection('faults')
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Fetch more to filter
          .get();

      final faults = snapshot.docs
          .map((doc) => FaultModel.fromDoc(doc))
          .where((fault) {
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          fault.location.lat,
          fault.location.lng,
        );
        return distance <= radiusInKm * 1000; // Convert km to meters
      }).take(limit).toList();

      return faults;
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load nearby faults: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load nearby faults: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<FaultModel>> getUserFaults(String userId) async {
    try {
      // Query without orderBy to avoid index requirement
      // Sorting will be done in memory by the cubit
      final snapshot = await firestore
          .collection('faults')
          .where('createdBy', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load user faults: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load user faults: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getTotalFaultsCount() async {
    try {
      final countSnapshot = await firestore
          .collection('faults')
          .count()
          .get();
      return countSnapshot.count ?? 0;
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get total faults count: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get total faults count: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getUserFaultsCount(String userId) async {
    try {
      final countSnapshot = await firestore
          .collection('faults')
          .where('createdBy', isEqualTo: userId)
          .count()
          .get();
      return countSnapshot.count ?? 0;
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get user faults count: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get user faults count: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
