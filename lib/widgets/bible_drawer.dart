import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_models.dart';

class BibleDrawer extends StatefulWidget {
  const BibleDrawer({super.key});

  @override
  State<BibleDrawer> createState() => _BibleDrawerState();
}

class _BibleDrawerState extends State<BibleDrawer> {
  Testament _selectedTestament = Testament.oldTestament;
  Book? _selectedBookForChapters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildRoyalHeader(context),
          const SizedBox(height: 16),
          _buildRoyalTestamentSelector(context),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _selectedBookForChapters == null
                  ? _buildRoyalBookList()
                  : _buildRoyalChapterGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 30, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.onPrimaryContainer],
            ).createShader(bounds),
            child: Icon(
              Icons.auto_stories,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'THE HOLY BIBLE',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 2,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalTestamentSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SegmentedButton<Testament>(
        segments: const [
          ButtonSegment<Testament>(
            value: Testament.oldTestament,
            label: Text('OLD COVENANT'),
          ),
          ButtonSegment<Testament>(
            value: Testament.newTestament,
            label: Text('NEW COVENANT'),
          ),
        ],
        selected: {_selectedTestament},
        showSelectedIcon: false,
        onSelectionChanged: (Set<Testament> newSelection) {
          setState(() {
            _selectedTestament = newSelection.first;
            _selectedBookForChapters = null;
          });
        },
      ),
    );
  }

  Widget _buildRoyalBookList() {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        final theme = Theme.of(context);
        final filteredBooks = bible.books
            .where((book) => book.testament == _selectedTestament)
            .toList();

        return ListView.separated(
          key: const ValueKey('bookList'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: filteredBooks.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
          ),
          itemBuilder: (context, index) {
            final book = filteredBooks[index];
            final isCurrentlyReading = bible.currentBook?.id == book.id;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                book.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isCurrentlyReading ? FontWeight.w900 : FontWeight.w500,
                  color: isCurrentlyReading ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: 20,
                color: isCurrentlyReading ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              onTap: () {
                setState(() {
                  _selectedBookForChapters = book;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRoyalChapterGrid() {
    final book = _selectedBookForChapters!;
    
    return Column(
      key: const ValueKey('chapterGrid'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => setState(() => _selectedBookForChapters = null),
            ),
            title: Text(
              book.name.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
            subtitle: Text(
              'SELECT CHAPTER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: book.chapterCount,
            itemBuilder: (context, index) {
              final chapterNumber = index + 1;
              return Consumer<BibleProvider>(
                builder: (context, bible, child) {
                  final theme = Theme.of(context);
                  final isCurrentlySelected =
                      bible.currentBook?.id == book.id &&
                      bible.currentChapter == chapterNumber;

                  return InkWell(
                    onTap: () {
                      bible.loadChapter(book.id, chapterNumber);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isCurrentlySelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrentlySelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: isCurrentlySelected ? 2 : 1,
                        ),
                        boxShadow: isCurrentlySelected ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          '$chapterNumber',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isCurrentlySelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: isCurrentlySelected ? FontWeight.w900 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
