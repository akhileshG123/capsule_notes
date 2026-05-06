import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../widgets/waveform_widget.dart';
import '../utils/theme.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isInit = false;
  String? _filePath;
  DateTime? _startTime;

  final _storage = StorageService();
  final _api = ApiService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Request microphone permission first
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record voice notes.')),
        );
      }
      return;
    }

    await _recorder.openRecorder();
    setState(() => _isInit = true);
  }

  Future<void> _startRecording() async {
    if (!_isInit) return;

    final tempDir = await getTemporaryDirectory();
    final id = const Uuid().v4();
    _filePath = '${tempDir.path}/$id.m4a';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    final duration = DateTime.now().difference(_startTime!).inSeconds.toDouble();
    if (duration < 1.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording too short')),
        );
      }
      return;
    }

    // Actually upload and transcribe the recording
    await _uploadAndTranscribe(duration);
  }

  Future<void> _uploadAndTranscribe(double duration) async {
    setState(() => _isProcessing = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _filePath == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final noteId = const Uuid().v4();
    final file = File(_filePath!);

    try {
      await FirebaseFirestore.instance.collection('voice_notes').doc(noteId).set({
        'userId': user.uid,
        'title': 'Voice Note - ${DateTime.now().toString().substring(0, 16)}',
        'transcript': 'Transcribing...',
        'audioUrl': '',
        'audioDuration': duration,
        'createdAt': Timestamp.now(),
        'isTranscribed': false,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing voice note in background...')),
        );
      }

      // Upload to Storage
      final audioUrl = await _storage.uploadVoiceNote(user.uid, noteId, file);
      if (audioUrl != null) {
        await FirebaseFirestore.instance.collection('voice_notes').doc(noteId).update({
          'audioUrl': audioUrl,
        });

        // Call Backend STT
        final success = await _api.transcribeAudio(noteId, user.uid, audioUrl);
        if (success) {
          await FirebaseFirestore.instance.collection('voice_notes').doc(noteId).update({
            'isTranscribed': true,
          });
        }
      } else {
        await FirebaseFirestore.instance.collection('voice_notes').doc(noteId).update({
          'transcript': 'Upload failed',
          'isTranscribed': true,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Voice Note',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) const WaveformWidget(),
            const SizedBox(height: 60),
            if (_isProcessing)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.accent),
                  const SizedBox(height: 16),
                  Text(
                    'Saving and processing audio...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            else
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 110 : 100,
                  height: _isRecording ? 110 : 100,
                  decoration: BoxDecoration(
                    gradient: _isRecording
                        ? const LinearGradient(
                            colors: [Color(0xFFE85B5B), Color(0xFFD44545)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accentLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording
                            ? const Color(0xFFE85B5B).withAlpha(80)
                            : AppTheme.accent.withAlpha(60),
                        blurRadius: _isRecording ? 30 : 16,
                        spreadRadius: _isRecording ? 4 : 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, size: 44, color: Colors.white),
                ),
              ),
            const SizedBox(height: 28),
            Text(
              _isProcessing
                  ? ''
                  : _isRecording
                      ? 'Release to stop and save'
                      : 'Hold to record',
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!_isInit && !_isProcessing) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.error.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Microphone permission is needed',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
