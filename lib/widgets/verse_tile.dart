import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';
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

  Color? _highlight() {
    final raw = verse.highlightColor;
    if (raw == null) return null;
    try {
      return Color(int.parse('0x${raw.replaceAll('#', '')}'));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fontSize = context.watch<ThemeProvider>().fontSize;
    final isRtl = context.watch<BibleProvider>().isRtl;
    final highlight = _highlight();
    final isDark = theme.brightness == Brightness.dark;
    final body = cleanVerseText(verse.text);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.fromLTRB(10, showHeader ? 10 : 6, 10, showHeader ? 10 : 6),
        decoration: BoxDecoration(
          color: highlight?.withValues(alpha: isDark ? 0.22 : 0.26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    verse.reference,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (!showHeader)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 7),
                                child: Text(
                                  '${verse.verse}',
                                  style: AppTheme.sans(
                                    fontSize: (fontSize * 0.62).clamp(11, 15).toDouble(),
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          TextSpan(text: body),
                        ],
                      ),
                      style: AppTheme.serif(
                        fontSize: fontSize,
                        height: 1.55,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (verse.isBookmarked)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 8, top: 2),
                      child: Icon(
                        Icons.bookmark_rounded,
                        size: 14,
                        color: scheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
