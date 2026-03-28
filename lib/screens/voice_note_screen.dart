import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
// import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
// import '../models/voice_note_model.dart';
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
  final _firestore = FirestoreService();
  final _api = ApiService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    _isInit = true;
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording too short')));
      return;
    }
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing voice note in background...')));
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
      appBar: AppBar(title: const Text('New Voice Note')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) const WaveformWidget(),
            const SizedBox(height: 60),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : AppTheme.accent,
                    shape: BoxShape.circle,
                    boxShadow: _isRecording 
                        ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]
                        : [],
                  ),
                  child: const Icon(Icons.mic, size: 50, color: Colors.white),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              _isProcessing 
                  ? 'Saving and processing audio...' 
                  : _isRecording ? 'Release to stop and save' : 'Hold to record',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
