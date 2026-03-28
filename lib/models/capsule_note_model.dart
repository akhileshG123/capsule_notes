import 'package:cloud_firestore/cloud_firestore.dart';

class CapsuleNoteModel {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime unlockAt;
  final bool isUnlocked;
  final bool isNotified;
  final String coverEmoji;

  CapsuleNoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.unlockAt,
    this.isUnlocked = false,
    this.isNotified = false,
    this.coverEmoji = '⏳',
  });

  factory CapsuleNoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CapsuleNoteModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unlockAt: (map['unlockAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUnlocked: map['isUnlocked'] ?? false,
      isNotified: map['isNotified'] ?? false,
      coverEmoji: map['coverEmoji'] ?? '⏳',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'unlockAt': Timestamp.fromDate(unlockAt),
      'isUnlocked': isUnlocked,
      'isNotified': isNotified,
      'coverEmoji': coverEmoji,
    };
  }
}
