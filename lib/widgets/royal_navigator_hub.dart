import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';

/// Classic mosaic book → chapter picker (restored).
class RoyalNavigatorHub extends StatefulWidget {
  const RoyalNavigatorHub({super.key});

  @override
  State<RoyalNavigatorHub> createState() => _RoyalNavigatorHubState();
}

class _RoyalNavigatorHubState extends State<RoyalNavigatorHub> {
  late Testament _selectedTestament;
  Book? _selectedBook;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bible = context.read<BibleProvider>();
    _selectedTestament = bible.currentBook?.testament ?? Testament.oldTestament;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bible = context.watch<BibleProvider>();
    final q = _searchQuery.trim().toLowerCase();
    final hasDeutero =
        bible.books.any((b) => b.testament == Testament.deuterocanonical);

    final filteredBooks = bible.books.where((b) {
      if (q.isNotEmpty) return b.name.toLowerCase().contains(q);
      return b.testament == _selectedTestament;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search books…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (_selectedBook == null && q.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 28,
                  runSpacing: 8,
                  children: [
                    _tab('OLD COVENANT', Testament.oldTestament),
                    _tab('NEW COVENANT', Testament.newTestament),
                    if (hasDeutero) _tab('DEUTEROCANON', Testament.deuterocanonical),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _selectedBook == null
                    ? _BookMosaic(
                        key: const ValueKey('books'),
                        books: filteredBooks,
                        currentId: bible.currentBook?.id,
                        onPick: (book) {
                          HapticFeedback.mediumImpact();
                          if (book.chapterCount <= 1) {
                            bible.loadChapter(book.id, 1);
                            Navigator.pop(context);
                            return;
                          }
                          setState(() => _selectedBook = book);
                        },
                      )
                    : _ChapterMosaic(
                        key: ValueKey('chapters-${_selectedBook!.id}'),
                        book: _selectedBook!,
                        currentChapter: bible.currentBook?.id == _selectedBook!.id
                            ? bible.currentChapter
                            : null,
                        onBack: () => setState(() => _selectedBook = null),
                        onPick: (chapter) {
                          HapticFeedback.selectionClick();
                          bible.loadChapter(_selectedBook!.id, chapter);
                          Navigator.pop(context);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, Testament testament) {
    final theme = Theme.of(context);
    final selected = _selectedTestament == testament;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTestament = testament;
          _selectedBook = null;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.35),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 1.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 2,
            width: selected ? 36 : 0,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _BookMosaic extends StatelessWidget {
  final List<Book> books;
  final String? currentId;
  final ValueChanged<Book> onPick;

  const _BookMosaic({
    super.key,
    required this.books,
    required this.currentId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 1200 ? 6 : (width > 800 ? 4 : 2);

    if (books.isEmpty) {
      return Center(
        child: Text(
          'No books match',
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.45,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final current = book.id == currentId;
            return Material(
              color: current ? scheme.primaryContainer : scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: current ? scheme.primary.withValues(alpha: 0.45) : scheme.outlineVariant,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onPick(book),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: current ? scheme.primary : scheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.chapterCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChapterMosaic extends StatelessWidget {
  final Book book;
  final int? currentChapter;
  final VoidCallback onBack;
  final ValueChanged<int> onPick;

  const _ChapterMosaic({
    super.key,
    required this.book,
    required this.currentChapter,
    required this.onBack,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: scheme.primary),
              ),
              Expanded(
                child: Text(
                  book.name.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${book.chapterCount} chapters',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 10 : 5;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: book.chapterCount,
                itemBuilder: (context, index) {
                  final chapter = index + 1;
                  final selected = chapter == currentChapter;
                  return Material(
                    color: selected ? scheme.primary : scheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? scheme.primary : scheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onPick(chapter),
                      child: Center(
                        child: Text(
                          '$chapter',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: selected ? scheme.onPrimary : scheme.onSurface,
                            fontWeight: FontWeight.w700,
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
