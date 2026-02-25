import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/verse_tile.dart';
import '../widgets/verse_action_toolbar.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks saved.'));
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
    );
  }
}
