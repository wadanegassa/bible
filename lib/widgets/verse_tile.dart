import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';

class VerseTile extends StatelessWidget {
  final Verse verse;
  final VoidCallback onBookmarkToggle;
  final bool showHeader;

  const VerseTile({
    super.key,
    required this.verse,
    required this.onBookmarkToggle,
    this.showHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                verse.reference,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${verse.verse} ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SelectableText(
                  verse.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              IconButton(
                icon: Icon(
                  verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: verse.isBookmarked ? Colors.blueGrey : null,
                ),
                onPressed: onBookmarkToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
