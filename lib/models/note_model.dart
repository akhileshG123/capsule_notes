import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final String type; // "text", "voice", "scanned", "capsule"
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final List<String> tags;

  NoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.tags = const [],
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoteModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: map['isPinned'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'tags': tags,
    };
  }
}
