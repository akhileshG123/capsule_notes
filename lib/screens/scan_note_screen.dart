import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
// import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
// import '../models/scanned_note_model.dart';
import '../utils/theme.dart';

class ScanNoteScreen extends StatefulWidget {
  const ScanNoteScreen({super.key});

  @override
  State<ScanNoteScreen> createState() => _ScanNoteScreenState();
}

class _ScanNoteScreenState extends State<ScanNoteScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  File? _imageFile;

  final _storage = StorageService();
  final _firestore = FirestoreService();
  final _api = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadAndExtract();
    }
  }

  Future<void> _uploadAndExtract() async {
    if (_imageFile == null) return;
    setState(() => _isProcessing = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final noteId = const Uuid().v4();

    try {
      await FirebaseFirestore.instance.collection('scanned_notes').doc(noteId).set({
        'userId': user.uid,
        'title': 'Scan - ${DateTime.now().toString().substring(0, 16)}',
        'extractedText': 'Processing text...',
        'imageUrl': '',
        'createdAt': Timestamp.now(),
        'isProcessed': false,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document scanning in background...')));
      }

      final imageUrl = await _storage.uploadScannedImage(user.uid, noteId, _imageFile!);
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('scanned_notes').doc(noteId).update({
          'imageUrl': imageUrl,
        });

        final success = await _api.extractText(noteId, user.uid, imageUrl);
        if (success) {
          await FirebaseFirestore.instance.collection('scanned_notes').doc(noteId).update({
            'isProcessed': true,
          });
        }
      } else {
        await FirebaseFirestore.instance.collection('scanned_notes').doc(noteId).update({
          'extractedText': 'Upload failed',
          'isProcessed': true,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Document')),
      body: Center(
        child: _isProcessing 
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading and processing...'),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.document_scanner, size: 80, color: AppTheme.cardScanned),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take a Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
