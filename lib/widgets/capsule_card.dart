import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/capsule_note_model.dart';
import '../utils/theme.dart';
import 'countdown_widget.dart';
import '../screens/note_detail_screen.dart';

class CapsuleCard extends StatelessWidget {
  final CapsuleNoteModel note;
  const CapsuleCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = !note.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardCapsule,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? const Color(0xFF7B5DAF).withAlpha(60) : AppTheme.divider,
          width: isLocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLocked
                ? const Color(0xFF7B5DAF).withAlpha(20)
                : AppTheme.shadow,
            blurRadius: isLocked ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailScreen(capsuleNote: note)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
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
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(note.coverEmoji, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isLocked)
                      Text(
                        note.content,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const SizedBox(height: 80),
                  ],
                ),
              ),
              if (isLocked)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(
                        color: AppTheme.cardCapsule.withAlpha(180),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B5DAF).withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: Color(0xFF7B5DAF),
                                  size: 24,
                                ),
                              ),
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
