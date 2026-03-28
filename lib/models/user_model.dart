import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
    };
  }
}
