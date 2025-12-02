import 'package:cloud_firestore/cloud_firestore.dart';

class FaultModel {
  final String id;
  final String type; // "water" | "electric" | "street" | "light" | "other"
  final String description;
  final String imageUrl;
  final FaultLocation location;
  final String status; // "pending" | "in-progress" | "done"
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String
  severity; // Kept as requested in previous prompt, though not in JSON above, user said "and severity as well"

  FaultModel({
    required this.id,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'imageUrl': imageUrl,
      'location': location.toMap(),
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'severity': severity,
    };
  }

  factory FaultModel.fromMap(Map<String, dynamic> map) {
    return FaultModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'other',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: FaultLocation.fromMap(map['location'] ?? {}),
      status: map['status'] ?? 'pending',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      severity: map['severity'] ?? 'Low',
    );
  }

  factory FaultModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FaultModel.fromMap(data);
  }
}

class FaultLocation {
  final double lat;
  final double lng;
  final String address;

  FaultLocation({required this.lat, required this.lng, required this.address});

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  factory FaultLocation.fromMap(Map<String, dynamic> map) {
    return FaultLocation(
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
    );
  }
}
