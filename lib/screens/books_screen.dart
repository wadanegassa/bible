import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/book_card.dart';
import 'chapters_screen.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holy Bible')),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Holy Bible...'),
                ],
              ),
            );
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
                    ElevatedButton(
                      onPressed: () => bible.init(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (bible.books.isEmpty) {
            return const Center(child: Text('No books available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bible.books.length,
            itemBuilder: (context, index) {
              final book = bible.books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChaptersScreen(book: book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
