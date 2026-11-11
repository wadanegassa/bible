import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';

class CompareScreen extends StatefulWidget {
  final Verse verse;

  const CompareScreen({super.key, required this.verse});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Map<String, Verse?> _rows = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bible = context.read<BibleProvider>();
    if (bible.compareIds.isEmpty) {
      final others = bible.downloadedVersions
          .where((v) => v.id != bible.currentTranslation)
          .take(2)
          .map((v) => v.id)
          .toList();
      if (others.isNotEmpty) await bible.setCompareIds(others);
    }
    final rows = await bible.compareVerse(widget.verse);
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bible = context.watch<BibleProvider>();
    final others = bible.downloadedVersions
        .where((v) => v.id != bible.currentTranslation)
        .toList();
    final textSize = bible.familyMode ? 21.0 : 18.0;

    return AppPage(
      title: widget.verse.reference,
      subtitle: 'Side by side in up to four translations',
      children: [
        if (others.isEmpty)
          Text(
            'Install another Bible from the library to compare.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in others)
                AppPill(
                  label: v.shortName,
                  icon: bible.compareIds.contains(v.id) ? Icons.check_rounded : null,
                  selected: bible.compareIds.contains(v.id),
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await bible.toggleCompareId(v.id);
                    setState(() => _loading = true);
                    await _load();
                  },
                ),
            ],
          ),
        const SizedBox(height: 24),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          for (final entry in _rows.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                padding: const EdgeInsets.fromLTRB(20, 10, 6, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bible.getVersionName(entry.key),
                            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                          ),
                        ),
                        if (entry.value != null) ...[
                          IconButton(
                            tooltip: 'Copy',
                            visualDensity: VisualDensity.compact,
                            color: scheme.onSurfaceVariant,
                            icon: const Icon(Icons.content_copy_rounded, size: 17),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                text: bible.formatVerseCopy(entry.value!, translationId: entry.key),
                              ));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Verse copied')),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Share',
                            visualDensity: VisualDensity.compact,
                            color: scheme.onSurfaceVariant,
                            icon: const Icon(Icons.ios_share_rounded, size: 17),
                            onPressed: () => SharePlus.instance.share(ShareParams(
                              text: bible.formatVerseCopy(entry.value!, translationId: entry.key),
                            )),
                          ),
                        ] else
                          const SizedBox(height: 40),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        entry.value == null
                            ? 'This verse isn’t in this translation.'
                            : cleanVerseText(entry.value!.text),
                        style: entry.value == null
                            ? theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)
                            : AppTheme.serif(
                                fontSize: textSize,
                                height: 1.6,
                                color: scheme.onSurface,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
