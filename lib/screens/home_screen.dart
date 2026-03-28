import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.white),
              title: const Text('Text Note'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppTheme.cardVoice),
              title: const Text('Voice Note'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceNoteScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner, color: AppTheme.cardScanned),
              title: const Text('Scan Document'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanNoteScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_clock, color: AppTheme.accent),
              title: const Text('Time Capsule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CapsuleNoteScreen()));
              },
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('CapsuleNotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppAuthProvider>().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Widget>>(
        stream: _getMixedNotesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Firestore error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Something went wrong', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Please try again later', style: TextStyle(color: Colors.grey[400])),
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
                  const Icon(Icons.note_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No notes yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first note', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.all(12),
            itemCount: widgets.length,
            itemBuilder: (context, index) {
              return widgets[index];
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

