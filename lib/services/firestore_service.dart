import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../models/capsule_note_model.dart';
import '../models/voice_note_model.dart';
import '../models/scanned_note_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Notes
  Stream<List<NoteModel>> getNotes(String userId) {
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addNote(NoteModel note) {
    return _db.collection('notes').add(note.toMap());
  }

  Future<void> updateNote(NoteModel note) {
    return _db.collection('notes').doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) {
    return _db.collection('notes').doc(noteId).delete();
  }

  // Capsule Notes
  Stream<List<CapsuleNoteModel>> getCapsuleNotes(String userId) {
    return _db
        .collection('capsule_notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CapsuleNoteModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> addCapsuleNote(CapsuleNoteModel note) async {
    final docRef = await _db.collection('capsule_notes').add(note.toMap());
    return docRef.id;
  }

  // Voice Notes
  Stream<List<VoiceNoteModel>> getVoiceNotes(String userId) {
    return _db
        .collection('voice_notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoiceNoteModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addVoiceNoteWithId(VoiceNoteModel note) async {
    await _db.collection('voice_notes').doc(note.id).set(note.toMap());
  }

  // Scanned Notes
  Stream<List<ScannedNoteModel>> getScannedNotes(String userId) {
    return _db
        .collection('scanned_notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScannedNoteModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> addScannedNote(ScannedNoteModel note) async {
    final docRef = await _db.collection('scanned_notes').add(note.toMap());
    return docRef.id;
  }

  Future<void> addScannedNoteWithId(ScannedNoteModel note) async {
    await _db.collection('scanned_notes').doc(note.id).set(note.toMap());
  }
}
