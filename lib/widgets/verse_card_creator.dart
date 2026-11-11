import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';

class VerseCardCreator extends StatelessWidget {
  final Verse verse;
  final String shareText;

  const VerseCardCreator({
    super.key,
    required this.verse,
    required this.shareText,
  });

  static void show(BuildContext context, Verse verse, {String? shareText}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => VerseCardCreator(
        verse: verse,
        shareText: shareText ?? '${cleanVerseText(verse.text)}\n\n— ${verse.reference}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final versionLine = shareText.contains(' · ')
        ? shareText.substring(shareText.lastIndexOf(' · ') + 3)
        : null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Share verse', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radius + 4),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '“',
                    style: AppTheme.serif(
                      fontSize: 48,
                      height: 0.7,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        cleanVerseText(verse.text),
                        style: AppTheme.serif(
                          fontSize: 21,
                          height: 1.55,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          verse.reference,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (versionLine != null)
                        Text(versionLine, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.content_copy_rounded, size: 18),
                    label: const Text('Copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      messenger.showSnackBar(const SnackBar(content: Text('Verse copied')));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text('Share'),
                    onPressed: () {
                      Navigator.pop(context);
                      SharePlus.instance.share(ShareParams(text: shareText));
                    },
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
