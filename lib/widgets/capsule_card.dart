import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../models/capsule_note_model.dart';
import '../utils/theme.dart';
import 'countdown_widget.dart';
import '../screens/note_detail_screen.dart';
import 'unlock_dialog.dart';

class CapsuleCard extends StatelessWidget {
  final CapsuleNoteModel note;
  const CapsuleCard({super.key, required this.note});

  /// Check if the capsule should actually be unlocked based on current time
  bool get _isTimeToUnlock => DateTime.now().isAfter(note.unlockAt);

  /// If time has passed but Firestore still says locked, update it
  Future<void> _autoUnlockIfNeeded(BuildContext context) async {
    if (_isTimeToUnlock && !note.isUnlocked && note.id != null) {
      await FirebaseFirestore.instance
          .collection('capsule_notes')
          .doc(note.id)
          .update({'isUnlocked': true});
    }
  }

  void _handleTap(BuildContext context) async {
    if (_isTimeToUnlock) {
      // Time has passed — auto-unlock in Firestore if needed, then open
      await _autoUnlockIfNeeded(context);

      // Show unlock celebration if first time opening
      if (!note.isUnlocked && context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => UnlockDialog(
            title: note.title,
            content: note.content,
          ),
        );
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailScreen(capsuleNote: note),
          ),
        );
      }
    } else {
      // Still locked — show a message
      final remaining = note.unlockAt.difference(DateTime.now());
      String timeLeft;
      if (remaining.inDays > 0) {
        timeLeft = '${remaining.inDays}d ${remaining.inHours % 24}h';
      } else if (remaining.inHours > 0) {
        timeLeft = '${remaining.inHours}h ${remaining.inMinutes % 60}m';
      } else {
        timeLeft = '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This capsule unlocks in $timeLeft',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7B5DAF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use runtime check, not just stored flag
    final bool isLocked = !_isTimeToUnlock;

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
        onTap: () => _handleTap(context),
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
