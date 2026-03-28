import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceNoteModel {
  final String? id;
  final String userId;
  final String title;
  final String transcript;
  final String audioUrl;
  final double audioDuration;
  final DateTime createdAt;
  final bool isTranscribed;

  VoiceNoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.transcript,
    required this.audioUrl,
    required this.audioDuration,
    required this.createdAt,
    this.isTranscribed = false,
  });

  factory VoiceNoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VoiceNoteModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      transcript: map['transcript'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      audioDuration: (map['audioDuration'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTranscribed: map['isTranscribed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'transcript': transcript,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'createdAt': Timestamp.fromDate(createdAt),
      'isTranscribed': isTranscribed,
    };
  }
}
