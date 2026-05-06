import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../utils/theme.dart';

class ScanNoteScreen extends StatefulWidget {
  const ScanNoteScreen({super.key});

  @override
  State<ScanNoteScreen> createState() => _ScanNoteScreenState();
}

class _ScanNoteScreenState extends State<ScanNoteScreen> {
  final ImagePicker _picker = ImagePicker();
  final _storage = StorageService();
  final _titleCtrl = TextEditingController();
  final _userNotesCtrl = TextEditingController();

  bool _isProcessing = false;
  bool _isSaving = false;
  File? _imageFile;
  String _extractedText = '';

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

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _extractedText = '';
      });
      _runOCR();
    }
  }

  Future<void> _runOCR() async {
    if (_imageFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });

      if (_extractedText.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text found in the image'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR error: $e')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : 'Scan - ${DateTime.now().toString().substring(0, 16)}';

    try {
      // Create Firestore doc first
      final docRef = await FirebaseFirestore.instance.collection('scanned_notes').add({
        'userId': user.uid,
        'title': title,
        'extractedText': _extractedText,
        'userNotes': _userNotesCtrl.text.trim(),
        'imageUrl': '',
        'createdAt': Timestamp.now(),
        'isProcessed': true,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved! Uploading image...')),
        );
      }

      // Upload image in background
      final imageUrl = await _storage.uploadScannedImage(
        user.uid,
        docRef.id,
        _imageFile!,
      );

      if (imageUrl != null) {
        await docRef.update({'imageUrl': imageUrl});
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _extractedText = '';
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _userNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Scan Document',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (_imageFile != null && !_isProcessing)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.check_rounded,
                          size: 18, color: AppTheme.accent),
                      label: Text(
                        'Save',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
        ],
      ),
      body: _imageFile == null ? _buildPickerView() : _buildPreviewView(),
    );
  }

  /// Initial view: pick image from camera or gallery
  Widget _buildPickerView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
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
              'Take a photo or choose from gallery.\nText will be extracted automatically.',
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
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w600),
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
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// After image is picked: show preview, OCR result, and notes field
  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextField(
            controller: _titleCtrl,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Document title (optional)',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              hintStyle: GoogleFonts.outfit(
                color: AppTheme.textHint,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 16),

          // Image preview
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _imageFile!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    // Replace image
                    _actionChip(
                      icon: Icons.refresh_rounded,
                      label: 'Replace',
                      onTap: () => _showReplaceOptions(),
                    ),
                    const SizedBox(width: 8),
                    // Remove image
                    _actionChip(
                      icon: Icons.close_rounded,
                      label: 'Remove',
                      onTap: _removeImage,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Extracted text section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47B4A).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.text_fields_rounded,
                    color: Color(0xFFC47B4A), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Extracted Text',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC47B4A),
                ),
              ),
              const Spacer(),
              if (_isProcessing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFFC47B4A).withAlpha(150),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: _isProcessing
                ? Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFFC47B4A).withAlpha(150),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Extracting text from image...',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _extractedText.isNotEmpty
                        ? _extractedText
                        : 'No text detected',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: _extractedText.isNotEmpty
                          ? AppTheme.textPrimary
                          : AppTheme.textHint,
                      height: 1.6,
                      fontStyle: _extractedText.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // User notes section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.note_alt_rounded,
                    color: AppTheme.accent, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Your Notes',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: TextField(
              controller: _userNotesCtrl,
              maxLines: null,
              minLines: 4,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.7,
              ),
              decoration: InputDecoration(
                hintText: 'Add your notes about this document...',
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintStyle: GoogleFonts.outfit(
                  color: AppTheme.textHint,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.error : AppTheme.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive
                ? AppTheme.error.withAlpha(40)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplaceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Replace Image',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFFC47B4A)),
              title: Text('Take a Photo',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFFC47B4A)),
              title: Text('Choose from Gallery',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
