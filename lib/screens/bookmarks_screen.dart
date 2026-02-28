import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/verse_tile.dart';
import '../widgets/verse_action_toolbar.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<BibleProvider>(
            builder: (context, bible, child) {
              if (bible.bookmarks.isEmpty) {
                return Center(
                  child: Text(
                    'No bookmarks saved.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bible.bookmarks.length,
                itemBuilder: (context, index) {
                  final verse = bible.bookmarks[index];
                  return VerseTile(
                    verse: verse,
                    showHeader: true,
                    onBookmarkToggle: () => bible.toggleBookmark(verse),
                    onTap: () => VerseActionToolbar.show(context, verse, bible),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
