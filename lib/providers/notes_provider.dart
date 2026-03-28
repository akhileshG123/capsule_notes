import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class NotesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> deleteNote(String noteId) async {
    await _firestoreService.deleteNote(noteId);
  }
}
