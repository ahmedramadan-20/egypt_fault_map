import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
  });

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "name": name,
    "email": email,
    "phone": phone,
    "profileImage": profileImage,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map["uid"],
    name: map["name"],
    email: map["email"],
    phone: map["phone"],
    profileImage: map["profileImage"],
  );

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for uid: ${doc.id}");
    }
    return AppUser.fromMap(data as Map<String, dynamic>);
  }
}
