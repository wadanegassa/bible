import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/verse_tile.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks saved.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarkProvider.bookmarks.length,
            itemBuilder: (context, index) {
              final verse = bookmarkProvider.bookmarks[index];
              return VerseTile(
                verse: verse,
                showHeader: true,
                onBookmarkToggle: () {
                  bookmarkProvider.toggleBookmark(verse);
                },
              );
            },
          );
        },
      ),
    );
  }
}
