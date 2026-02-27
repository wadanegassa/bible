import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/bible_models.dart';
import '../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final highlightColor = _getHighlightColor();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 0.5), // Minimal gap
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tighter vertical padding
        decoration: BoxDecoration(
          color: highlightColor ?? 
                 (verse.isBookmarked ? theme.colorScheme.primary.withValues(alpha: 0.05) : null),
          borderRadius: BorderRadius.circular(0), // Sharp block look as in image
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  verse.reference.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${verse.verse}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: highlightColor != null ? Colors.white70 : theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    verse.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      fontSize: themeProvider.fontSize,
                      color: highlightColor != null ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (verse.isBookmarked && highlightColor == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.bookmark,
                      size: 16,
                      color: theme.colorScheme.primary,
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
