import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';
import '../screens/compare_screen.dart';
import 'verse_card_creator.dart';

class VerseActionToolbar extends StatelessWidget {
  final Verse verse;
  final ValueChanged<String?> onHighlight;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onNote;
  final VoidCallback onCompare;

  const VerseActionToolbar({
    super.key,
    required this.verse,
    required this.onHighlight,
    required this.onBookmark,
    required this.onCopy,
    required this.onShare,
    required this.onNote,
    required this.onCompare,
  });

  static const highlightColors = <String, Color>{
    'Honey': Color(0xFFE9C46A),
    'Sage': Color(0xFF9CC5A1),
    'Sky': Color(0xFF8DB8E0),
    'Rose': Color(0xFFE8A0A8),
    'Lavender': Color(0xFFB8A6DA),
  };

  static String hexOf(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';

  static void show(BuildContext context, Verse verse, BibleProvider bible) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => VerseActionToolbar(
        verse: verse,
        onHighlight: (color) {
          bible.updateHighlight(verse, color);
          Navigator.pop(sheetContext);
        },
        onBookmark: () {
          bible.toggleBookmark(verse);
          Navigator.pop(sheetContext);
          messenger.showSnackBar(SnackBar(
            content: Text(verse.isBookmarked ? 'Removed from saved' : 'Saved'),
          ));
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(text: bible.formatVerseCopy(verse)));
          Navigator.pop(sheetContext);
          messenger.showSnackBar(const SnackBar(content: Text('Verse copied')));
        },
        onShare: () {
          Navigator.pop(sheetContext);
          VerseCardCreator.show(context, verse, shareText: bible.formatVerseCopy(verse));
        },
        onNote: () {
          Navigator.pop(sheetContext);
          _showNoteEditor(context, verse, bible);
        },
        onCompare: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CompareScreen(verse: verse)),
          );
        },
      ),
    );
  }

  static Future<void> _showNoteEditor(
    BuildContext context,
    Verse verse,
    BibleProvider bible,
  ) async {
    final existing = await bible.getNoteForVerse(verse);
    if (!context.mounted) return;
    final controller = TextEditingController(text: existing ?? '');
    final messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(verse.reference, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                cleanVerseText(verse.text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 8,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: bible.familyMode ? 18 : 15,
                  height: 1.5,
                ),
                decoration: const InputDecoration(hintText: 'What stands out to you?'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (existing != null && existing.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await bible.saveNote(verse, '');
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        messenger.showSnackBar(const SnackBar(content: Text('Note deleted')));
                      },
                      child: const Text('Delete'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await bible.saveNote(verse, controller.text);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      messenger.showSnackBar(SnackBar(
                        content: Text(
                          controller.text.trim().isEmpty ? 'Note removed' : 'Note saved',
                        ),
                      ));
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(verse.reference, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              cleanVerseText(verse.text),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.serif(fontSize: 16, height: 1.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final entry in highlightColors.entries)
                  _Swatch(
                    color: entry.value,
                    label: entry.key,
                    selected: verse.highlightColor?.toLowerCase() == hexOf(entry.value),
                    onTap: () => onHighlight(hexOf(entry.value)),
                  ),
                _Swatch(
                  label: 'Clear highlight',
                  selected: false,
                  enabled: verse.highlightColor != null,
                  onTap: () => onHighlight(null),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 6),
            Row(
              children: [
                _Action(
                  icon: verse.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  label: verse.isBookmarked ? 'Saved' : 'Save',
                  active: verse.isBookmarked,
                  onTap: onBookmark,
                ),
                _Action(icon: Icons.edit_note_rounded, label: 'Note', onTap: onNote),
                _Action(icon: Icons.compare_arrows_rounded, label: 'Compare', onTap: onCompare),
                _Action(icon: Icons.content_copy_rounded, label: 'Copy', onTap: onCopy),
                _Action(icon: Icons.ios_share_rounded, label: 'Share', onTap: onShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color? color;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _Swatch({
    this.color,
    required this.label,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: Tooltip(
        message: label,
        child: InkResponse(
          radius: 26,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color ?? Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? scheme.onSurface
                    : color == null
                        ? scheme.outlineVariant
                        : Colors.transparent,
                width: selected ? 2 : 1,
              ),
            ),
            child: color == null
                ? Icon(
                    Icons.block_rounded,
                    size: 18,
                    color: enabled ? scheme.onSurfaceVariant : scheme.outlineVariant,
                  )
                : selected
                    ? const Icon(Icons.check_rounded, size: 18, color: Color(0xFF1E1C19))
                    : null,
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = active ? scheme.primary : scheme.onSurface;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: active ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
