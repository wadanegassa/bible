import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_models.dart';
import '../widgets/verse_tile.dart';
import '../widgets/royal_navigator_hub.dart';
import '../widgets/verse_action_toolbar.dart';
import '../widgets/verse_card_creator.dart';
import 'search_screen.dart';
import '../providers/theme_provider.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isManuscriptMode = false;

  void _showNavigatorHub(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Navigator Hub',
      pageBuilder: (context, anim1, anim2) => const RoyalNavigatorHub(),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        final bookName = bible.currentBook?.name ?? '';
        final chapterNum = bible.currentChapter?.toString() ?? '';
        final theme = Theme.of(context);

        return Scaffold(
          body: GestureDetector(
            onDoubleTap: () {
              HapticFeedback.heavyImpact();
              setState(() => _isManuscriptMode = !_isManuscriptMode);
            },
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    if (!_isManuscriptMode)
                      _buildRoyalAppBar(context, bible, bookName, chapterNum),
                    if (!_isManuscriptMode)
                      SliverToBoxAdapter(
                        child: LinearProgressIndicator(
                          value: bible.bookProgress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary.withValues(alpha: 0.5)),
                          minHeight: 2,
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: bible.isInitializing
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    if (bible.loadingMessage != null) ...[
                                      const SizedBox(height: 24),
                                      Text(
                                        bible.loadingMessage!,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          : bible.errorMessage != null
                              ? SliverFillRemaining(child: _buildErrorView(bible.errorMessage!))
                              : bible.verses.isEmpty
                                  ? SliverFillRemaining(child: _buildEmptyVersesView(context, bible))
                                  : _buildVersesSliverList(bible),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
                if (!_isManuscriptMode)
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: _buildMagicOrbControl(context, bible),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagicOrbControl(BuildContext context, BibleProvider bible) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMiniNavButton(Icons.chevron_left, () {
              HapticFeedback.lightImpact();
              bible.prevChapter();
            }),
            _buildMagicOrb(context),
            _buildMiniNavButton(Icons.chevron_right, () {
              HapticFeedback.lightImpact();
              bible.nextChapter();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniNavButton(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
      ),
    );
  }

  Widget _buildMagicOrb(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showNavigatorHub(context);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.auto_stories, color: theme.colorScheme.onPrimary, size: 30),
      ),
    );
  }

  Widget _buildRoyalAppBar(BuildContext context, BibleProvider bible, String bookName, String chapterNum) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: true,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leadingWidth: 110,
      leading: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: theme.colorScheme.onSurface, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()));
            },
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bookName.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                fontSize: 9,
              ),
            ),
            Text(
              'Chapter $chapterNum',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        _buildRoyalLanguagePicker(context, bible),
        const SizedBox(width: 12),
      ],
    );
  }


  Widget _buildRoyalLanguagePicker(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);
    final currentVersion = bible.availableVersions.firstWhere(
      (v) => v.id == bible.currentTranslation,
      orElse: () => bible.availableVersions.first,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 45),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentVersion.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary, size: 20),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) => bible.availableVersions
              .map((version) => PopupMenuItem<String>(
                    value: version.id,
                    child: _buildPopupItem(
                      context,
                      version.id.contains('AMHARIC') ? Icons.language : Icons.translate,
                      version.fullname,
                      isDownloaded: version.isDownloaded,
                    ),
                  ))
              .toList(),
          onSelected: (String versionId) {
            final version = bible.availableVersions.firstWhere((v) => v.id == versionId);
            if (version.isDownloaded) {
              bible.setTranslation(versionId);
            } else {
              bible.downloadVersion(version);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPopupItem(BuildContext context, IconData icon, String text, {bool isDownloaded = true}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: isDownloaded ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: isDownloaded ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
        ),
        if (!isDownloaded)
          Icon(Icons.file_download_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildEmptyVersesView(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            'The Word is waiting...',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showNavigatorHub(context),
            child: Text('SELECT A BOOK', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesSliverList(BibleProvider bible) {
    return SliverList(
      key: const ValueKey('verses'),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final verse = bible.verses[index];
          return VerseTile(
            verse: verse,
            onBookmarkToggle: () {
              bible.toggleBookmark(verse);
            },
            onTap: () {
              HapticFeedback.mediumImpact();
              VerseActionToolbar.show(context, verse, bible);
            },
          );
        },
        childCount: bible.verses.length,
      ),
    );
  }
}
