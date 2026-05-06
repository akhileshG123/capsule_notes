import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scanned_note_model.dart';
import '../utils/theme.dart';
import '../screens/note_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScannedCard extends StatelessWidget {
  final ScannedNoteModel note;
  const ScannedCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardScanned,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: const [
          BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailScreen(scannedNote: note)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            if (note.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: note.imageUrl,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.surfaceVariant,
                    height: 100,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                    color: AppTheme.surfaceVariant,
                    height: 100,
                    child: const Center(child: Icon(Icons.broken_image_rounded, color: AppTheme.textHint)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC47B4A).withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.document_scanner_rounded, color: Color(0xFFC47B4A), size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!note.isProcessed)
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFFC47B4A).withAlpha(150),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Extracting text...',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      note.extractedText,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
