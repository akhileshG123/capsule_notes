import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';

class UnlockDialog extends StatelessWidget {
  final String title;
  final String content;

  const UnlockDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accent.withAlpha(60), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withAlpha(20),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_open_rounded, size: 48, color: AppTheme.accent),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: Lottie.network(
              'https://lottie.host/8061bc4a-dbd1-4680-baac-850d90fc9239/O5UqHhFqN6.json',
              repeat: false,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
