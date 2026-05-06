import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/note_model.dart';
import '../models/voice_note_model.dart';
import '../models/scanned_note_model.dart';
import '../models/capsule_note_model.dart';
import '../utils/theme.dart';

/// A unified full-screen detail view for every note type.
/// Pass exactly ONE of [note], [voiceNote], [scannedNote], or [capsuleNote].
class NoteDetailScreen extends StatefulWidget {
  final NoteModel? note;
  final VoiceNoteModel? voiceNote;
  final ScannedNoteModel? scannedNote;
  final CapsuleNoteModel? capsuleNote;

  const NoteDetailScreen({
    super.key,
    this.note,
    this.voiceNote,
    this.scannedNote,
    this.capsuleNote,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;

  // ── helpers ──────────────────────────────────────────────────
  String get _noteType {
    if (widget.note != null) return 'text';
    if (widget.voiceNote != null) return 'voice';
    if (widget.scannedNote != null) return 'scanned';
    if (widget.capsuleNote != null) return 'capsule';
    return 'text';
  }

  String get _title {
    if (widget.note != null) return widget.note!.title;
    if (widget.voiceNote != null) return widget.voiceNote!.title;
    if (widget.scannedNote != null) return widget.scannedNote!.title;
    if (widget.capsuleNote != null) return widget.capsuleNote!.title;
    return '';
  }

  String get _content {
    if (widget.note != null) return widget.note!.content;
    if (widget.voiceNote != null) return widget.voiceNote!.transcript;
    if (widget.scannedNote != null) return widget.scannedNote!.extractedText;
    if (widget.capsuleNote != null) return widget.capsuleNote!.content;
    return '';
  }

  String? get _docId {
    if (widget.note != null) return widget.note!.id;
    if (widget.voiceNote != null) return widget.voiceNote!.id;
    if (widget.scannedNote != null) return widget.scannedNote!.id;
    if (widget.capsuleNote != null) return widget.capsuleNote!.id;
    return null;
  }

  String get _collectionName {
    switch (_noteType) {
      case 'voice':
        return 'voice_notes';
      case 'scanned':
        return 'scanned_notes';
      case 'capsule':
        return 'capsule_notes';
      default:
        return 'notes';
    }
  }

  String get _contentFieldName {
    switch (_noteType) {
      case 'voice':
        return 'transcript';
      case 'scanned':
        return 'extractedText';
      default:
        return 'content';
    }
  }

  IconData get _typeIcon {
    switch (_noteType) {
      case 'voice':
        return Icons.mic_rounded;
      case 'scanned':
        return Icons.document_scanner_rounded;
      case 'capsule':
        return Icons.lock_clock_rounded;
      default:
        return Icons.text_fields_rounded;
    }
  }

  Color get _typeColor {
    switch (_noteType) {
      case 'voice':
        return const Color(0xFF4A8CAF);
      case 'scanned':
        return const Color(0xFFC47B4A);
      case 'capsule':
        return const Color(0xFF7B5DAF);
      default:
        return AppTheme.accent;
    }
  }

  Color get _typeBg {
    switch (_noteType) {
      case 'voice':
        return AppTheme.cardVoice;
      case 'scanned':
        return AppTheme.cardScanned;
      case 'capsule':
        return AppTheme.cardCapsule;
      default:
        return AppTheme.cardText;
    }
  }

  String get _typeLabel {
    switch (_noteType) {
      case 'voice':
        return 'Voice Note';
      case 'scanned':
        return 'Scanned Note';
      case 'capsule':
        return 'Capsule Note';
      default:
        return 'Text Note';
    }
  }

  DateTime get _createdAt {
    if (widget.note != null) return widget.note!.createdAt;
    if (widget.voiceNote != null) return widget.voiceNote!.createdAt;
    if (widget.scannedNote != null) return widget.scannedNote!.createdAt;
    if (widget.capsuleNote != null) return widget.capsuleNote!.createdAt;
    return DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: _title);
    _contentCtrl = TextEditingController(text: _content);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Edit ─────────────────────────────────────────────────────
  void _startEditing() {
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdit() async {
    final docId = _docId;
    if (docId == null) return;

    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        _contentFieldName: _contentCtrl.text.trim(),
      };
      if (_noteType == 'text') {
        updates['updatedAt'] = Timestamp.now();
      }
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(docId)
          .update(updates);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote() async {
    final docId = _docId;
    if (docId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(docId)
          .delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Note' : _typeLabel,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (_isEditing)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: _saveEdit,
                      icon: const Icon(Icons.check_rounded,
                          size: 18, color: AppTheme.accent),
                      label: Text(
                        'Save',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: AppTheme.surface,
              elevation: 4,
              onSelected: (value) {
                if (value == 'edit') _startEditing();
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded,
                          size: 20, color: AppTheme.accent),
                      const SizedBox(width: 12),
                      Text(
                        'Edit',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_rounded,
                          size: 20, color: AppTheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type badge + date ─────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _typeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _typeColor.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, size: 14, color: _typeColor),
                      const SizedBox(width: 6),
                      Text(
                        _typeLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(_createdAt),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Scanned image ─────────────────────────────
            if (_noteType == 'scanned' &&
                widget.scannedNote!.imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: widget.scannedNote!.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: AppTheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accent),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppTheme.surfaceVariant,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: AppTheme.textHint, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Voice info ────────────────────────────────
            if (_noteType == 'voice') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardVoice,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF4A8CAF).withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A8CAF).withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Color(0xFF4A8CAF), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio Duration',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${widget.voiceNote!.audioDuration.toStringAsFixed(0)} seconds',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Capsule info ──────────────────────────────
            if (_noteType == 'capsule') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardCapsule,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF7B5DAF).withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Text(widget.capsuleNote!.coverEmoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.capsuleNote!.isUnlocked
                                ? 'Unlocked'
                                : 'Locked',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Unlocks ${_formatDate(widget.capsuleNote!.unlockAt)}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      widget.capsuleNote!.isUnlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      color: const Color(0xFF7B5DAF),
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Title ─────────────────────────────────────
            if (_isEditing)
              TextField(
                controller: _titleCtrl,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: GoogleFonts.outfit(
                    color: AppTheme.textHint,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Text(
                _title,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),

            const SizedBox(height: 4),
            const Divider(color: AppTheme.divider, height: 24),

            // ── Content ───────────────────────────────────
            if (_isEditing)
              TextField(
                controller: _contentCtrl,
                maxLines: null,
                minLines: 12,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  height: 1.8,
                ),
                decoration: InputDecoration(
                  hintText: 'Note content...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: GoogleFonts.outfit(
                    color: AppTheme.textHint,
                    fontSize: 16,
                  ),
                ),
              )
            else
              Text(
                _content,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.8,
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$min $period';
  }
}
