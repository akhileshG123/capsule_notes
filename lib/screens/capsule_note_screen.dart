import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      if (!mounted) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick a time')),
      );
      return;
    }

    final unlockAt = DateTime(
      _unlockDate!.year, _unlockDate!.month, _unlockDate!.day,
      _unlockTime!.hour, _unlockTime!.minute,
    );

    if (unlockAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unlock time must be in the future')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time capsule saved!')),
        );
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Time Capsule',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _saveCapsule,
                icon: const Icon(Icons.check_rounded, size: 18, color: AppTheme.accent),
                label: Text('Save', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.accent)),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: DropdownButton<String>(
                    value: _emoji,
                    dropdownColor: AppTheme.surface,
                    underline: const SizedBox(),
                    items: _emojis.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 24)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _emoji = val);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _titleCtrl,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Capsule Title',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textHint, fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardCapsule,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF7B5DAF).withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B5DAF).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.timer_rounded, color: Color(0xFF7B5DAF), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _unlockDate == null
                            ? 'Set Unlock Date & Time'
                            : '${DateFormat.yMMMd().format(_unlockDate!)} at ${_unlockTime!.format(context)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: _unlockDate == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary, height: 1.7),
                decoration: InputDecoration(
                  hintText: 'Write your future note...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: GoogleFonts.outfit(color: AppTheme.textHint, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}