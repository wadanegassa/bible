import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../providers/bible_provider.dart';
import '../screens/library_screen.dart';
import '../screens/plans_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/today_screen.dart';
import 'app_surface.dart';

enum AppDest {
  read,
  books,
  today,
  saved,
  plans,
  library,
  settings,
}

class AppDrawer extends StatelessWidget {
  final AppDest current;

  const AppDrawer({super.key, required this.current});

  void _go(BuildContext context, Widget Function(VoidCallback backToReader) page) {
    HapticFeedback.selectionClick();
    final nav = Navigator.of(context);
    void backToReader() => nav.popUntil((route) => route.isFirst);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => page(backToReader)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bible = context.watch<BibleProvider>();
    final version = bible.currentVersion;
    final daily = bible.dailyVerse;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Holy Bible',
                    style: AppTheme.serif(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (version != null) '${version.shortName} · ${version.language}',
                      if (bible.streak > 1) '${bible.streak}-day streak',
                    ].join('  ·  '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (daily != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    await bible.openDailyVerse();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verse of the day', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 10),
                        AppQuote(
                          text: cleanVerseText(daily.text),
                          reference: daily.reference,
                          fontSize: 16,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Divider(color: scheme.outlineVariant),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _item(
                    context,
                    icon: Icons.menu_book_outlined,
                    label: 'Read',
                    selected: current == AppDest.read,
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..popUntil((r) => r.isFirst),
                  ),
                  _item(
                    context,
                    icon: Icons.wb_twilight_rounded,
                    label: 'Today',
                    selected: current == AppDest.today,
                    onTap: () => _go(context, (back) => TodayScreen(onOpenReader: back)),
                  ),
                  _item(
                    context,
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Saved',
                    selected: current == AppDest.saved,
                    onTap: () => _go(context, (back) => SavedScreen(onOpenReader: back)),
                  ),
                  _item(
                    context,
                    icon: Icons.event_note_outlined,
                    label: 'Reading plans',
                    selected: current == AppDest.plans,
                    onTap: () => _go(context, (back) => PlansScreen(onOpenReader: back)),
                  ),
                  _item(
                    context,
                    icon: Icons.library_books_outlined,
                    label: 'Bible library',
                    selected: current == AppDest.library,
                    onTap: () => _go(context, (_) => const LibraryScreen()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _item(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: current == AppDest.settings,
                onTap: () => _go(context, (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 21, color: selected ? fg : scheme.onSurfaceVariant),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
