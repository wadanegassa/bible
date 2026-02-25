import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_models.dart';
import '../widgets/verse_tile.dart';
import '../widgets/royal_navigator_hub.dart';
import '../widgets/verse_action_toolbar.dart';
import '../widgets/verse_card_creator.dart';

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
                      sliver: bible.isLoading
                          ? const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
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
        _buildRoyalLanguagePicker(context, bible),
        const SizedBox(width: 12),
      ],
    );
  }


  Widget _buildRoyalLanguagePicker(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.translate, color: theme.colorScheme.primary, size: 20),
        tooltip: 'Select Language',
        onSelected: (String language) {
          bible.setTranslation(language);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'AMHARIC',
            child: _buildPopupItem(Icons.language, 'አማርኛ (Amharic)'),
          ),
          PopupMenuItem<String>(
            value: 'KJV',
            child: _buildPopupItem(Icons.language, 'English (KJV)'),
          ),
        ],
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
