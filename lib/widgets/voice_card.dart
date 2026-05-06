import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/voice_note_model.dart';
import '../utils/theme.dart';
import '../screens/note_detail_screen.dart';

class VoiceCard extends StatelessWidget {
  final VoiceNoteModel note;
  const VoiceCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardVoice,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: const [
          BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailScreen(voiceNote: note)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A8CAF).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF4A8CAF), size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${note.audioDuration.toStringAsFixed(0)}s',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (!note.isTranscribed)
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF4A8CAF).withAlpha(150),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transcribing...',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  note.transcript,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
