import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/bible_version_models.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';

  bool _matches(BibleVersion v) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return v.fullname.toLowerCase().contains(q) ||
        v.shortName.toLowerCase().contains(q) ||
        v.language.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bible = context.watch<BibleProvider>();

    final defaults = bible.defaultVersions;
    final defaultIds = defaults.map((v) => v.id).toSet();
    final byLanguage = <String, List<BibleVersion>>{};
    for (final v in bible.availableVersions) {
      if (defaultIds.contains(v.id) || !_matches(v)) continue;
      byLanguage.putIfAbsent(v.language, () => []).add(v);
    }
    final shownDefaults = defaults.where(_matches).toList();

    return AppPage(
      title: 'Bible library',
      subtitle: 'Three Bibles are built in. Add more for offline reading.',
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: const InputDecoration(
            hintText: 'Filter by name or language',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 28),
        if (shownDefaults.isNotEmpty) ...[
          const AppSectionLabel('Always available'),
          AppGroup(
            children: [
              for (final v in shownDefaults) _VersionRow(version: v, bible: bible),
            ],
          ),
          const SizedBox(height: 28),
        ],
        for (final entry in byLanguage.entries) ...[
          AppSectionLabel(entry.key),
          AppGroup(
            children: [
              for (final v in entry.value) _VersionRow(version: v, bible: bible),
            ],
          ),
          const SizedBox(height: 28),
        ],
        if (shownDefaults.isEmpty && byLanguage.isEmpty)
          const AppEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing found',
            subtitle: 'Try a language like “Amharic” or “Oromo”.',
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Open-licensed texts may be shared with attribution. Publisher-restricted '
            'editions are for personal, non-commercial reading. Commercial English '
            'editions such as NIV and ESV are not included.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _VersionRow extends StatelessWidget {
  final BibleVersion version;
  final BibleProvider bible;

  const _VersionRow({required this.version, required this.bible});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final installing = bible.installingId == version.id;
    final isCurrent = bible.currentTranslation == version.id;
    final busy = bible.installingId != null;

    final details = [
      version.shortName,
      version.scopeLabel,
      if (!version.isDownloaded && version.sizeLabel.isNotEmpty) version.sizeLabel,
    ].join(' · ');

    Widget trailing;
    if (installing) {
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (!version.isDownloaded) {
      trailing = OutlinedButton(
        onPressed: busy
            ? null
            : () {
                HapticFeedback.selectionClick();
                bible.installVersion(version);
              },
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: const Text('Install'),
      );
    } else if (isCurrent) {
      trailing = Text(
        'Reading',
        style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
      );
    } else {
      trailing = PopupMenuButton<String>(
        tooltip: 'Options',
        icon: Icon(Icons.more_horiz_rounded, color: scheme.onSurfaceVariant),
        onSelected: (action) async {
          if (action == 'open') {
            await bible.setTranslation(version.id);
            if (context.mounted) Navigator.pop(context);
          } else if (action == 'remove') {
            await _confirmRemove(context);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'open', child: Text('Read this version')),
          if (!version.bundled)
            const PopupMenuItem(value: 'remove', child: Text('Remove download')),
        ],
      );
    }

    return AppRow(
      title: version.fullname,
      subtitle: details,
      trailing: trailing,
      onTap: version.isDownloaded && !isCurrent
          ? () async {
              await bible.setTranslation(version.id);
              if (context.mounted) Navigator.pop(context);
            }
          : null,
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove download?'),
        content: Text('${version.fullname} will be removed from this device. '
            'You can install it again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await bible.uninstallVersion(version);
  }
}
