import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/verse_tile.dart';

class VersesScreen extends StatelessWidget {
  final String bookName;
  final String chapterName;

  const VersesScreen({
    super.key,
    required this.bookName,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$bookName $chapterName')),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bible.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(bible.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    // No easy retry here since parameters are needed, 
                    // but we could call the load function again if we stored params
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bible.verses.length,
            itemBuilder: (context, index) {
              final verse = bible.verses[index];
              return VerseTile(
                verse: verse,
                onBookmarkToggle: () {
                  context.read<BookmarkProvider>().toggleBookmark(verse);
                },
              );
            },
          );
        },
      ),
    );
  }
}
