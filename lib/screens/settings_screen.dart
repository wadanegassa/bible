import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/bible_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_surface.dart';
import 'library_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final bible = context.watch<BibleProvider>();
    final installedExtras =
        bible.downloadedVersions.where((v) => !v.bundled).length;

    return AppPage(
      title: 'Settings',
      children: [
        const AppSectionLabel('Reading'),
        AppGroup(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Text size',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${themeProvider.fontSize.round()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'In the beginning was the Word, and the Word was with God.',
                    style: AppTheme.serif(
                      fontSize: themeProvider.fontSize,
                      height: 1.55,
                      color: scheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Text('A', style: AppTheme.serif(fontSize: 13, color: scheme.onSurfaceVariant)),
                      Expanded(
                        child: Slider(
                          value: themeProvider.fontSize.clamp(14, 36),
                          min: 14,
                          max: 36,
                          divisions: 11,
                          onChanged: themeProvider.setFontSize,
                        ),
                      ),
                      Text('A', style: AppTheme.serif(fontSize: 22, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            _SwitchRow(
              icon: Icons.dark_mode_outlined,
              title: 'Dark mode',
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
            _SwitchRow(
              icon: Icons.groups_outlined,
              title: 'Family mode',
              subtitle: 'Larger text for reading together',
              value: bible.familyMode,
              onChanged: (value) {
                bible.setFamilyMode(value);
                if (value && themeProvider.fontSize < 22) {
                  themeProvider.setFontSize(22);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AppSectionLabel('Daily reading'),
        AppGroup(
          children: [
            _SwitchRow(
              icon: Icons.notifications_none_rounded,
              title: 'Reminder',
              subtitle: 'A gentle nudge on Today if you haven’t read',
              value: bible.reminderEnabled,
              onChanged: (value) => bible.setReminder(enabled: value),
            ),
            if (bible.reminderEnabled)
              AppRow(
                icon: Icons.schedule_rounded,
                title: 'Time',
                trailing: Text(
                  TimeOfDay(hour: bible.reminderHour, minute: bible.reminderMinute)
                      .format(context),
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.primary),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: bible.reminderHour,
                      minute: bible.reminderMinute,
                    ),
                  );
                  if (picked == null) return;
                  await bible.setReminder(
                    enabled: true,
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 28),
        const AppSectionLabel('Library'),
        AppGroup(
          children: [
            AppRow(
              icon: Icons.library_books_outlined,
              title: 'Bible library',
              subtitle: installedExtras == 0
                  ? 'Oromo, Amharic, English and more'
                  : '$installedExtras extra ${installedExtras == 1 ? 'Bible' : 'Bibles'} downloaded',
              showChevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AppSectionLabel('About'),
        AppGroup(
          children: [
            const AppRow(
              icon: Icons.info_outline_rounded,
              title: 'Holy Bible',
              subtitle: 'Version 1.0 · Works fully offline. Each translation '
                  'remains the property of its publisher.',
            ),
          ],
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          onChanged(v);
        },
      ),
    );
  }
}
