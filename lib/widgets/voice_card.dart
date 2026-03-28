import 'package:flutter/material.dart';
import '../models/voice_note_model.dart';
import '../utils/theme.dart';

class VoiceCard extends StatelessWidget {
  final VoiceNoteModel note;
  const VoiceCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardVoice,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.mic, color: Colors.white70),
                  Text('${note.audioDuration.toStringAsFixed(1)}s', style: const TextStyle(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (!note.isTranscribed)
                const Row(
                  children: [
                    SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Transcribing...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                )
              else
                Text(
                  note.transcript,
                  style: const TextStyle(color: Colors.white70),
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
