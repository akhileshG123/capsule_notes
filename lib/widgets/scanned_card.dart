import 'package:flutter/material.dart';
import '../models/scanned_note_model.dart';
import '../utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScannedCard extends StatelessWidget {
  final ScannedNoteModel note;
  const ScannedCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardScanned,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: note.imageUrl,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black12, height: 120, width: 100, child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, err) => Container(color: Colors.black26, height: 120, width: 100, child: const Icon(Icons.error)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.document_scanner, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!note.isProcessed)
                      const Row(
                        children: [
                          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Extracting...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      )
                    else
                      Text(
                        note.extractedText,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
