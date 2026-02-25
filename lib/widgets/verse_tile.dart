import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';

class VerseTile extends StatelessWidget {
  final Verse verse;
  final VoidCallback onBookmarkToggle;
  final bool showHeader;
  final VoidCallback onTap;

  const VerseTile({
    super.key,
    required this.verse,
    required this.onBookmarkToggle,
    required this.onTap,
    this.showHeader = false,
  });

  Color? _getHighlightColor() {
    if (verse.highlightColor == null) return null;
    try {
      final hexColor = verse.highlightColor!.replaceAll('#', '');
      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = _getHighlightColor();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: highlightColor?.withValues(alpha: 0.15) ?? 
                 (verse.isBookmarked ? theme.colorScheme.primary.withValues(alpha: 0.03) : null),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlightColor?.withValues(alpha: 0.3) ?? 
                   (verse.isBookmarked ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  verse.reference.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 35,
                  child: Text(
                    '${verse.verse}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: highlightColor ?? theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    verse.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                if (verse.isBookmarked && highlightColor == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.bookmark,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
