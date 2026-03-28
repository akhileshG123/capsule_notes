import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
// import '../models/note_model.dart';
// import '../utils/theme.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _firestore = FirestoreService();
  bool _isSaving = false;
  void _saveNote() async {
    if (_titleCtrl.text.isEmpty && _contentCtrl.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'userId': user.uid,
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'type': 'text',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isPinned': false,
        'tags': [],
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved!')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                decoration: const InputDecoration(
                  hintText: 'Note something down...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
