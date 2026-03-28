import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../utils/theme.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardText,
      child: InkWell(
        onTap: () {
          // Open Note Details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
