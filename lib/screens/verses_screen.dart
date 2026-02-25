import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/verse_tile.dart';
import '../widgets/verse_action_toolbar.dart';

class VersesScreen extends StatelessWidget {
  const VersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        final bookName = bible.currentBook?.name ?? '';
        final chapterNum = bible.currentChapter?.toString() ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('$bookName $chapterNum'),
          ),
          body: bible.isLoading
              ? const Center(child: CircularProgressIndicator())
              : bible.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(bible.errorMessage!, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bible.verses.length,
                      itemBuilder: (context, index) {
                        final verse = bible.verses[index];
                        return VerseTile(
                          verse: verse,
                          onBookmarkToggle: () {
                            bible.toggleBookmark(verse);
                          },
                          onTap: () => VerseActionToolbar.show(context, verse, bible),
                        );
                      },
                    ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: () => bible.prevChapter(),
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.arrow_back),
                ),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: () => bible.nextChapter(),
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
