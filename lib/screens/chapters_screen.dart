import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import 'verses_screen.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class ChaptersScreen extends StatelessWidget {
  final Book book;

  const ChaptersScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: book.chapterCount,
        itemBuilder: (context, index) {
          final chapterNum = index + 1;
          return InkWell(
            onTap: () {
              context.read<BibleProvider>().loadVerses(book.id, chapterNum);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VersesScreen(
                    bookName: book.name,
                    chapterName: chapterNum.toString(),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chapterNum.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
