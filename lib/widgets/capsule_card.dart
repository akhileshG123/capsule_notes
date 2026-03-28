import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/capsule_note_model.dart';
import '../utils/theme.dart';
import 'countdown_widget.dart';

class CapsuleCard extends StatelessWidget {
  final CapsuleNoteModel note;
  const CapsuleCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = !note.isUnlocked;

    return Card(
      color: AppTheme.cardCapsule,
      elevation: isLocked ? 8 : 4,
      shadowColor: isLocked ? AppTheme.accent.withOpacity(0.5) : Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLocked ? const BorderSide(color: AppTheme.accent, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // Open Capsule Note Details
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(note.coverEmoji, style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isLocked)
                      Text(
                        note.content,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Container(
                        height: 80, // Space for blur
                        width: double.infinity,
                      )
                  ],
                ),
              ),
              if (isLocked)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Colors.white, size: 32),
                              const SizedBox(height: 8),
                              CountdownWidget(unlockAt: note.unlockAt),
                            ],
                          ),
                        ),
                      ),
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
