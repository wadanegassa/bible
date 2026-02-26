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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
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
        child: const Icon(Icons.auto_stories, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildRoyalAppBar(BuildContext context, BibleProvider bible, String bookName, String chapterNum) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      stretch: true,
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
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
                fontSize: 10,
              ),
            ),
            Text(
              'Chapter $chapterNum',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.05),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: theme.colorScheme.primary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
          },
        ),
        _buildRoyalLanguagePicker(context, bible),
        const SizedBox(width: 12),
      ],
    );
  }


  Widget _buildRoyalLanguagePicker(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);
    final currentVersion = bible.availableVersions.firstWhere((v) => v.id == bible.currentTranslation);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D0A0A), // Dark red/black background from screenshot
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
              ],
            ),
          ),
          onSelected: (String versionId) {
            bible.setTranslation(versionId);
          },
          itemBuilder: (BuildContext context) => bible.availableVersions
              .where((v) => v.isDownloaded)
              .map((version) => PopupMenuItem<String>(
                    value: version.id,
                    child: _buildPopupItem(
                      version.id.contains('AMHARIC') ? Icons.language : Icons.translate,
                      version.fullname,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPopupItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(text),
      ],
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
