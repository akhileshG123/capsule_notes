import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
// import '../models/capsule_note_model.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class CapsuleNoteScreen extends StatefulWidget {
  const CapsuleNoteScreen({super.key});

  @override
  State<CapsuleNoteScreen> createState() => _CapsuleNoteScreenState();
}

class _CapsuleNoteScreenState extends State<CapsuleNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _firestore = FirestoreService();
  bool _isSaving = false;
  DateTime? _unlockDate;
  TimeOfDay? _unlockTime;
  String _emoji = '🔒';

  final List<String> _emojis = ['🔒', '🎁', '💌', '🕰️', '💎', '🚀'];

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _unlockDate = date;
          _unlockTime = time;
        });
      }
    }
  }

  void _saveCapsule() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty || _unlockDate == null || _unlockTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and pick a time')));
      return;
    }

    final unlockAt = DateTime(
      _unlockDate!.year, _unlockDate!.month, _unlockDate!.day,
      _unlockTime!.hour, _unlockTime!.minute,
    );

    if (unlockAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unlock time must be in the future')));
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('capsule_notes').add({
        'userId': user.uid,
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'createdAt': Timestamp.now(),
        'unlockAt': Timestamp.fromDate(unlockAt),
        'isUnlocked': false,
        'isNotified': false,
        'coverEmoji': _emoji,
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
        title: const Text('Time Capsule'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveCapsule,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _emoji,
                  dropdownColor: AppTheme.cardCapsule,
                  items: _emojis.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 24)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _emoji = val);
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Capsule Title', border: InputBorder.none),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: AppTheme.cardCapsule,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.timer, color: AppTheme.accent),
              title: Text(_unlockDate == null 
                  ? 'Set Unlock Date & Time' 
                  : '${DateFormat.yMMMd().format(_unlockDate!)} at ${_unlockTime!.format(context)}'),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                decoration: const InputDecoration(hintText: 'Write your future note...', border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  