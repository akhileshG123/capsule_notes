import 'package:cloud_firestore/cloud_firestore.dart';

class ScannedNoteModel {
  final String? id;
  final String userId;
  final String title;
  final String extractedText;
  final String imageUrl;
  final DateTime createdAt;
  final bool isProcessed;

  ScannedNoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.extractedText,
    required this.imageUrl,
    required this.createdAt,
    this.isProcessed = false,
  });

  factory ScannedNoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScannedNoteModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      extractedText: map['extractedText'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isProcessed: map['isProcessed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'extractedText': extractedText,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProcessed': isProcessed,
    };
  }
}
