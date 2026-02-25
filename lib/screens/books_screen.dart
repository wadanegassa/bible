import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_models.dart';
import '../widgets/book_card.dart';
import 'chapters_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  int _selectedIndex = 0; // 0: Old Testimony, 1: New Testimony

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final List<Book> filteredBooks = bible.books.where((b) {
            if (_selectedIndex == 0) return b.testament == Testament.oldTestament;
            return b.testament == Testament.newTestament;
          }).toList();

          if (filteredBooks.isEmpty) {
            return const Center(child: Text('No books available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
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
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildSelectionButton(0, 'Old Testimony'),
              _buildSelectionButton(1, 'New Testimony'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(int index, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
