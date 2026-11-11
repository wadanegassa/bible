import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/models/bible_version_models.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_surface.dart';
import '../widgets/royal_navigator_hub.dart';
import '../widgets/verse_action_toolbar.dart';
import '../widgets/verse_tile.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  bool _focusMode = false;
  String? _shownPassage;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openBookPicker() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const RoyalNavigatorHub(),
      ),
    );
  }

  void _resetScrollOnNewPassage(BibleProvider bible) {
    final passage =
        '${bible.currentTranslation}.${bible.currentBook?.id}.${bible.currentChapter}';
    if (passage == _shownPassage) return;
    _shownPassage = passage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, _) {
        _resetScrollOnNewPassage(bible);
        final ready = !bible.isInitializing &&
            bible.errorMessage == null &&
            bible.verses.isNotEmpty;

        return Scaffold(
          drawer: const AppDrawer(current: AppDest.read),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () {
              HapticFeedback.lightImpact();
              setState(() => _focusMode = !_focusMode);
            },
            onHorizontalDragEnd: ready
                ? (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v.abs() < 450) return;
                    HapticFeedback.selectionClick();
                    v < 0 ? bible.nextChapter() : bible.prevChapter();
                  }
                : null,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scroll,
                  slivers: [
                    if (!_focusMode) _ReaderAppBar(bible: bible),
                    if (_focusMode)
                      SliverToBoxAdapter(
                        child: SizedBox(height: MediaQuery.paddingOf(context).top + 12),
                      ),
                    ..._body(context, bible),
                  ],
                ),
                if (ready && !_focusMode)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Center(
                          child: _PassageControls(
                            bible: bible,
                            onPickPassage: _openBookPicker,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);

    if (bible.isInitializing) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 16),
                Text(
                  bible.loadingMessage ?? 'Opening Bible…',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (bible.errorMessage != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'This chapter didn’t open',
            subtitle: bible.errorMessage!,
            actionLabel: 'Try again',
            onAction: () => bible.init(),
          ),
        ),
      ];
    }

    if (bible.verses.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Choose where to begin',
            subtitle: 'Pick a book and chapter to start reading.',
            actionLabel: 'Browse books',
            onAction: _openBookPicker,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        sliver: SliverToBoxAdapter(
          child: AppColumn(
            maxWidth: 680,
            child: _ChapterHeading(bible: bible),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        sliver: SliverList.builder(
          itemCount: bible.verses.length,
          itemBuilder: (context, index) {
            final verse = bible.verses[index];
            return AppColumn(
              maxWidth: 680,
              child: VerseTile(
                verse: verse,
                onBookmarkToggle: () => bible.toggleBookmark(verse),
                onTap: () {
                  HapticFeedback.selectionClick();
                  VerseActionToolbar.show(context, verse, bible);
                },
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(height: _focusMode ? 48 : 120),
      ),
    ];
  }
}

class _ReaderAppBar extends StatelessWidget {
  final BibleProvider bible;

  const _ReaderAppBar({required this.bible});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = bible.currentBook?.name;
    final chapter = bible.currentChapter;
    final title = book == null || book.isEmpty
        ? 'Holy Bible'
        : '$book ${chapter ?? ''}'.trim();

    return SliverAppBar(
      floating: true,
      snap: true,
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            HapticFeedback.selectionClick();
            Scaffold.of(ctx).openDrawer();
          },
        ),
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      actions: [
        _VersionMenu(bible: bible),
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: LinearProgressIndicator(
          value: bible.bookProgress.clamp(0.0, 1.0),
          minHeight: 2,
          backgroundColor: Colors.transparent,
          color: theme.colorScheme.primary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _ChapterHeading extends StatelessWidget {
  final BibleProvider bible;

  const _ChapterHeading({required this.bible});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final book = bible.currentBook?.name ?? '';
    final chapter = bible.currentChapter;

    // Same inset as VerseTile content so the header lines up with the verses.
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book,
              textAlign: TextAlign.start,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${chapter ?? ''}',
              textAlign: TextAlign.start,
              style: AppTheme.serif(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom on-screen controls: previous · open books · next.
class _PassageControls extends StatelessWidget {
  final BibleProvider bible;
  final VoidCallback onPickPassage;

  const _PassageControls({
    required this.bible,
    required this.onPickPassage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final books = bible.books;
    final book = bible.currentBook;
    final chapter = bible.currentChapter ?? 1;
    final index = book == null ? -1 : books.indexWhere((b) => b.id == book.id);
    final hasPrev = chapter > 1 || index > 0;
    final hasNext = book != null &&
        (chapter < book.chapterCount || (index != -1 && index < books.length - 1));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavCircle(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous chapter',
            enabled: hasPrev,
            onTap: () {
              HapticFeedback.selectionClick();
              bible.prevChapter();
            },
          ),
          Tooltip(
            message: 'Choose book & chapter',
            child: Material(
              color: scheme.primary,
              shape: const CircleBorder(),
              elevation: theme.brightness == Brightness.dark ? 6 : 3,
              shadowColor: Colors.black.withValues(alpha: 0.35),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onPickPassage();
                },
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: scheme.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          _NavCircle(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Next chapter',
            enabled: hasNext,
            onTap: () {
              HapticFeedback.selectionClick();
              bible.nextChapter();
            },
          ),
        ],
      ),
    );
  }
}

class _NavCircle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _NavCircle({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              size: 22,
              color: enabled ? scheme.onSurface : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionMenu extends StatelessWidget {
  final BibleProvider bible;

  const _VersionMenu({required this.bible});

  @override
  Widget build(BuildContext context) {
    final versions = bible.versionCardVersions;
    if (versions.isEmpty) return const SizedBox.shrink();
    final current = versions.firstWhere(
      (v) => v.id == bible.currentTranslation,
      orElse: () => versions.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PopupMenuButton<String>(
        tooltip: 'Change version',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
        onSelected: (id) {
          if (id == '__library__') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LibraryScreen()),
            );
            return;
          }
          HapticFeedback.selectionClick();
          bible.setTranslation(id);
        },
        itemBuilder: (context) {
          final defaults = bible.defaultVersions;
          final defaultIds = defaults.map((v) => v.id).toSet();
          final extras = versions.where((v) => !defaultIds.contains(v.id));
          return [
            for (final v in defaults) _item(context, v),
            if (extras.isNotEmpty) const PopupMenuDivider(),
            for (final v in extras) _item(context, v),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: '__library__',
              child: Row(
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'More Bibles',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ];
        },
        child: IgnorePointer(
          child: AppPill(
            label: current.shortName,
            trailingIcon: Icons.arrow_drop_down_rounded,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(BuildContext context, BibleVersion v) {
    final theme = Theme.of(context);
    final selected = v.id == bible.currentTranslation;
    return PopupMenuItem<String>(
      value: v.id,
      height: 58,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: selected
                ? Icon(Icons.check_rounded, size: 18, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  v.shortName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? theme.colorScheme.primary : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${v.language} · ${v.fullname}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
