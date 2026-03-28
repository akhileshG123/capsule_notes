import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardCapsule,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent, width: 2), // Glowing effect
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_open, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Text(content, style: const TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Awesome!', style: TextStyle(color: Colors.white)),
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
