import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import '../widgets/waveform_widget.dart';
import '../utils/theme.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isSaving = false;
  String _recognizedText = '';
  String _liveText = '';
  double _confidence = 0.0;
  DateTime? _startTime;

  final _titleCtrl = TextEditingController();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _liveText = '';
      _startTime = DateTime.now();
    });

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          _liveText = result.recognizedWords;
          if (result.hasConfidenceRating) {
            _confidence = result.confidence;
          }
          if (result.finalResult) {
            // Append finalized text
            if (_recognizedText.isNotEmpty && _liveText.isNotEmpty) {
              _recognizedText += ' $_liveText';
            } else {
              _recognizedText += _liveText;
            }
            _liveText = '';
          }
        });
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      localeId: 'en_US',
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      // Merge any remaining live text
      if (_liveText.isNotEmpty) {
        if (_recognizedText.isNotEmpty) {
          _recognizedText += ' $_liveText';
        } else {
          _recognizedText = _liveText;
        }
        _liveText = '';
      }
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  Future<void> _saveVoiceNote() async {
    final transcript = _recognizedText.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to save. Record something first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds.toDouble()
        : 0.0;

    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : 'Voice Note - ${DateTime.now().toString().substring(0, 16)}';

    try {
      await FirebaseFirestore.instance.collection('voice_notes').add({
        'userId': user.uid,
        'title': title,
        'transcript': transcript,
        'audioUrl': '',
        'audioDuration': duration,
        'createdAt': Timestamp.now(),
        'isTranscribed': true,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note saved!')),
        );
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

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  String get _displayText {
    if (_recognizedText.isNotEmpty && _liveText.isNotEmpty) {
      return '$_recognizedText $_liveText';
    }
    if (_liveText.isNotEmpty) return _liveText;
    if (_recognizedText.isNotEmpty) return _recognizedText;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _displayText.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'New Voice Note',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (hasText && !_isListening)
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
                      onPressed: _saveVoiceNote,
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Note title (optional)',
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

            // Transcript area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardVoice,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF4A8CAF).withAlpha(80)
                        : AppTheme.divider,
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: hasText
                    ? SingleChildScrollView(
                        child: Text(
                          _displayText,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            height: 1.7,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_none_rounded,
                              size: 48,
                              color: AppTheme.textHint.withAlpha(120),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isListening
                                  ? 'Listening...'
                                  : 'Tap the mic to start speaking',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: AppTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Waveform when listening
            if (_isListening) ...[
              const WaveformWidget(),
              const SizedBox(height: 12),
            ],

            // Confidence indicator
            if (_confidence > 0 && hasText)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_rounded,
                        size: 14, color: AppTheme.textHint),
                    const SizedBox(width: 6),
                    Text(
                      'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),

            // Mic button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clear button
                if (hasText && !_isListening)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _recognizedText = '';
                        _liveText = '';
                        _confidence = 0;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.error.withAlpha(40)),
                      ),
                      child: const Icon(Icons.clear_rounded,
                          color: AppTheme.error, size: 24),
                    ),
                  ),

                if (hasText && !_isListening) const SizedBox(width: 24),

                // Main mic button
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnim.value : 1.0,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: _isListening
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFE85B5B),
                                      Color(0xFFD44545)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [
                                      AppTheme.accent,
                                      AppTheme.accentLight
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isListening
                                    ? const Color(0xFFE85B5B).withAlpha(80)
                                    : AppTheme.accent.withAlpha(60),
                                blurRadius: _isListening ? 30 : 16,
                                spreadRadius: _isListening ? 4 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              _isListening ? 'Tap to stop' : (hasText ? 'Tap to continue' : 'Tap to start speaking'),
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Availability warning
            if (!_isAvailable) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.error.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Speech recognition not available',
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
