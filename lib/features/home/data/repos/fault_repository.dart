import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fault_model.dart';

class FaultRepository {
  final FirebaseFirestore firestore;

  FaultRepository(this.firestore);

  Future<void> addFault(FaultModel fault) async {
    await firestore.collection('faults').doc(fault.id).set(fault.toMap());
  }

  Future<List<FaultModel>> getAllFaults() async {
    final snapshot = await firestore.collection('faults').get();
    return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
  }
}
