import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/plans/reading_plans.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';

class PlansScreen extends StatelessWidget {
  final VoidCallback onOpenReader;

  const PlansScreen({super.key, required this.onOpenReader});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, _) {
        final active = bible.activePlan;
        final others =
            ReadingPlans.all.where((p) => p.id != bible.activePlanId).toList();

        return AppPage(
          title: 'Reading plans',
          subtitle: 'One chapter a day, at your own pace.',
          children: [
            if (active != null) ...[
              _ActivePlan(
                plan: active,
                day: bible.activePlanDay,
                completed: bible.planCompletedDays,
                progress: bible.planProgress,
                onOpenDay: (day) async {
                  HapticFeedback.selectionClick();
                  await bible.openPlanDay(day);
                  onOpenReader();
                },
                onComplete: (day) async {
                  HapticFeedback.lightImpact();
                  await bible.completePlanDay(day);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Day $day complete')),
                  );
                },
                onStop: () => _confirmStop(context, bible),
              ),
              const SizedBox(height: 32),
            ],
            if (others.isNotEmpty) ...[
              AppSectionLabel(active == null ? 'Choose a plan' : 'More plans'),
              AppGroup(
                children: [
                  for (final plan in others)
                    AppRow(
                      title: plan.title,
                      subtitle: '${plan.subtitle} · ${plan.length} days',
                      trailing: TextButton(
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          if (active != null) {
                            final ok = await _confirmSwitch(context);
                            if (!ok) return;
                          }
                          await bible.startPlan(plan.id);
                          await bible.openPlanDay(plan.days.first);
                          onOpenReader();
                        },
                        child: const Text('Start'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<bool> _confirmSwitch(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch plans?'),
        content: const Text('Your progress in the current plan will be reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _confirmStop(BuildContext context, BibleProvider bible) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop this plan?'),
        content: const Text('You can start it again any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop plan'),
          ),
        ],
      ),
    );
    if (result == true) await bible.clearPlan();
  }
}

class _ActivePlan extends StatelessWidget {
  final ReadingPlan plan;
  final int day;
  final List<int> completed;
  final double progress;
  final ValueChanged<PlanDay> onOpenDay;
  final ValueChanged<int> onComplete;
  final VoidCallback onStop;

  const _ActivePlan({
    required this.plan,
    required this.day,
    required this.completed,
    required this.progress,
    required this.onOpenDay,
    required this.onComplete,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = plan.days.firstWhere(
      (d) => d.day == day,
      orElse: () => plan.days.first,
    );
    final doneToday = completed.contains(current.day);

    return AppSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Plan options',
                  icon: Icon(Icons.more_horiz_rounded, color: scheme.onSurfaceVariant),
                  onSelected: (_) => onStop(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'stop', child: Text('Stop plan')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.title,
                  style: AppTheme.serif(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day $day of ${plan.length}  ·  ${completed.length} done',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => onOpenDay(current),
                        child: const Text('Read today'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: doneToday ? null : () => onComplete(current.day),
                        icon: Icon(doneToday ? Icons.check_rounded : Icons.done_rounded, size: 18),
                        label: Text(doneToday ? 'Done' : 'Mark done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text('All days', style: theme.textTheme.bodyMedium),
              children: [
                for (final d in plan.days)
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      completed.contains(d.day)
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 20,
                      color: completed.contains(d.day)
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                    title: Text(
                      d.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: d.day == day ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: Text('Day ${d.day}', style: theme.textTheme.bodySmall),
                    onTap: () => onOpenDay(d),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
