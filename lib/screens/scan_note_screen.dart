import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/api_service.dart';
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
  final _api = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    // Request appropriate permission
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required.')),
          );
        }
        return;
      }
    }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document scanning in background...')),
        );
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
      appBar: AppBar(
        title: Text(
          'Scan Document',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.accent),
                  const SizedBox(height: 20),
                  Text(
                    'Uploading and processing...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardScanned,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        size: 56,
                        color: Color(0xFFC47B4A),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Scan your document',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a photo or choose from gallery to extract text',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, size: 20),
                        label: Text(
                          'Take a Photo',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 20),
                        label: Text(
                          'Choose from Gallery',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
