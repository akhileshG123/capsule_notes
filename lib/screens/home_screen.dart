import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/note_card.dart';
import '../widgets/capsule_card.dart';
import '../widgets/voice_card.dart';
import '../widgets/scanned_card.dart';
import '../utils/theme.dart';
import 'create_note_screen.dart';
import 'voice_note_screen.dart';
import 'scan_note_screen.dart';
import 'capsule_note_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirestoreService _firestore = FirestoreService();

  Stream<List<Widget>> _getMixedNotesStream(String userId) {
    return CombineLatestStream.list<List<dynamic>>([
      _firestore.getNotes(userId),
      _firestore.getCapsuleNotes(userId),
      _firestore.getVoiceNotes(userId),
      _firestore.getScannedNotes(userId),
    ]).map((listOfLists) {
      final allItems = listOfLists.expand((i) => i).toList();
      allItems.sort((a, b) {
        bool aPinned = (a.runtimeType.toString() == 'NoteModel') ? (a as dynamic).isPinned : false;
        bool bPinned = (b.runtimeType.toString() == 'NoteModel') ? (b as dynamic).isPinned : false;
        if (aPinned && !bPinned) return -1;
        if (!aPinned && bPinned) return 1;
        return ((b as dynamic).createdAt as DateTime).compareTo((a as dynamic).createdAt as DateTime);
      });

      return allItems.map((item) {
        if (item.runtimeType.toString() == 'NoteModel') return NoteCard(note: item);
        if (item.runtimeType.toString() == 'CapsuleNoteModel') return CapsuleCard(note: item);
        if (item.runtimeType.toString() == 'VoiceNoteModel') return VoiceCard(note: item);
        if (item.runtimeType.toString() == 'ScannedNoteModel') return ScannedCard(note: item);
        return const SizedBox.shrink();
      }).toList();
    });
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create New Note',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _CreateOptionTile(
                  icon: Icons.text_fields_rounded,
                  label: 'Text',
                  color: AppTheme.cardText,
                  iconColor: AppTheme.accent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _CreateOptionTile(
                  icon: Icons.mic_rounded,
                  label: 'Voice',
                  color: AppTheme.cardVoice,
                  iconColor: const Color(0xFF4A8CAF),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceNoteScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _CreateOptionTile(
                  icon: Icons.document_scanner_rounded,
                  label: 'Scan',
                  color: AppTheme.cardScanned,
                  iconColor: const Color(0xFFC47B4A),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanNoteScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _CreateOptionTile(
                  icon: Icons.lock_clock_rounded,
                  label: 'Capsule',
                  color: AppTheme.cardCapsule,
                  iconColor: const Color(0xFF7B5DAF),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CapsuleNoteScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().user;
    if (user == null) return const Scaffold();

    final firstName = (user.displayName ?? 'there').split(' ').first;

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $firstName 👋',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Capture your thoughts',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              toolbarHeight: 68,
            )
          : AppBar(
              title: Text(
                'Profile',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
      body: _currentIndex == 0 ? _buildNotesBody(user.uid) : const ProfileScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showCreateOptions,
              elevation: 4,
              child: const Icon(Icons.add_rounded, size: 30),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesBody(String userId) {
    return StreamBuilder<List<Widget>>(
      stream: _getMixedNotesStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }
        if (snapshot.hasError) {
          debugPrint('Firestore error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please try again later',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final widgets = snapshot.data ?? [];
        if (widgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.note_add_rounded, size: 48, color: AppTheme.accent),
                ),
                const SizedBox(height: 20),
                Text(
                  'No notes yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap + to create your first note',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            return widgets[index];
          },
        );
      },
    );
  }
}

// ── Create Option Tile ──────────────────────────────────────────
class _CreateOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _CreateOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
