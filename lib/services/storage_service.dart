import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadVoiceNote(String userId, String noteId, File audioFile) async {
    try {
      final ref = _storage.ref().child('audio/$userId/$noteId.m4a');
      final uploadTask = await ref.putFile(audioFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Upload voice note error: $e');
      return null;
    }
  }

  Future<String?> uploadScannedImage(String userId, String noteId, File imageFile) async {
    try {
      final ref = _storage.ref().child('scans/$userId/$noteId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Upload scanned image error: $e');
      return null;
    }
  }
}
