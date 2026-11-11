import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/utils/verse_text.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';
import '../widgets/verse_card_creator.dart';

class TodayScreen extends StatelessWidget {
  final VoidCallback onOpenReader;

  const TodayScreen({super.key, required this.onOpenReader});

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _date(DateTime now) =>
      '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Consumer<BibleProvider>(
      builder: (context, bible, _) {
        final daily = bible.dailyVerse;
        final plan = bible.activePlan;
        final family = bible.familyMode;

        final streakNote = bible.streak > 1
            ? '${bible.streak} days in a row'
            : bible.readToday
                ? 'You’ve read today'
                : null;

        return AppPage(
          title: _greeting(now),
          subtitle: [_date(now), ?streakNote].join('  ·  '),
          children: [
            AppSurface(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verse of the day', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 14),
                  if (daily == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14, right: 8),
                      child: Text(
                        'Your verse will appear once the Bible has opened.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppQuote(
                        text: cleanVerseText(daily.text),
                        reference:
                            '${daily.reference} · ${bible.getVersionName(bible.currentTranslation)}',
                        fontSize: family ? 22 : 19,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Copy',
                          icon: const Icon(Icons.content_copy_rounded, size: 19),
                          color: theme.colorScheme.onSurfaceVariant,
                          onPressed: () async {
                            HapticFeedback.selectionClick();
                            await Clipboard.setData(
                              ClipboardData(text: bible.formatVerseCopy(daily)),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verse copied')),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Share',
                          icon: const Icon(Icons.ios_share_rounded, size: 19),
                          color: theme.colorScheme.onSurfaceVariant,
                          onPressed: () => VerseCardCreator.show(
                            context,
                            daily,
                            shareText: bible.formatVerseCopy(daily),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            await bible.openDailyVerse();
                            onOpenReader();
                          },
                          child: const Text('Read chapter'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            const AppSectionLabel('Pick up where you left off'),
            AppGroup(
              children: [
                AppRow(
                  icon: Icons.menu_book_outlined,
                  title: bible.continueLabel ?? 'Start reading',
                  subtitle: bible.currentVersion?.fullname,
                  showChevron: true,
                  onTap: () async {
                    await bible.continueReading();
                    onOpenReader();
                  },
                ),
                if (plan != null)
                  AppRow(
                    icon: Icons.event_note_outlined,
                    title: plan.title,
                    subtitle: 'Day ${bible.activePlanDay} of ${plan.length}',
                    trailing: Text(
                      '${(bible.planProgress * 100).round()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    showChevron: true,
                    onTap: () async {
                      final day = plan.days.firstWhere(
                        (d) => d.day == bible.activePlanDay,
                        orElse: () => plan.days.first,
                      );
                      await bible.openPlanDay(day);
                      onOpenReader();
                    },
                  ),
                if (bible.reminderEnabled && !bible.readToday)
                  AppRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Reminder set for ${_time(bible.reminderHour, bible.reminderMinute)}',
                  ),
              ],
            ),
            if (bible.history.isNotEmpty) ...[
              const SizedBox(height: 28),
              const AppSectionLabel('Recently read'),
              AppGroup(
                children: [
                  for (final row in bible.history.take(5))
                    AppRow(
                      title: '${row['book_name'] ?? ''} ${row['chapter'] ?? ''}',
                      subtitle: bible.getVersionName(row['translation'] as String? ?? ''),
                      showChevron: true,
                      onTap: () async {
                        final translation = row['translation'] as String? ?? '';
                        if (translation.isNotEmpty &&
                            translation != bible.currentTranslation) {
                          await bible.setTranslation(translation);
                        }
                        await bible.loadChapter(
                          row['book_id'] as String? ?? '',
                          row['chapter'] as int? ?? 1,
                        );
                        onOpenReader();
                      },
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  String _time(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
