import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_models.dart';
import '../screens/versions_screen.dart';

class RoyalNavigatorHub extends StatefulWidget {
  const RoyalNavigatorHub({super.key});

  @override
  State<RoyalNavigatorHub> createState() => _RoyalNavigatorHubState();
}

class _RoyalNavigatorHubState extends State<RoyalNavigatorHub> {
  Testament _selectedTestament = Testament.oldTestament;
  Book? _selectedBook;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bible = Provider.of<BibleProvider>(context);
    
    List<Book> filteredBooks = bible.books
        .where((b) => b.testament == _selectedTestament)
        .where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.98),
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(context),
                _buildVersionDownloaderButton(context),
                if (_selectedBook == null) _buildReadingStats(context, bible),
                if (_selectedBook == null) _buildTestamentTabs(context),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _selectedBook == null
                        ? _buildBookMosaic(filteredBooks)
                        : _buildChapterMosaic(_selectedBook!),
                  ),
                ),
                _buildActionButton(context),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search books...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTestamentTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItem('OLD COVENANT', Testament.oldTestament),
          const SizedBox(width: 30),
          _buildTabItem('NEW COVENANT', Testament.newTestament),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, Testament testament) {
    final isSelected = _selectedTestament == testament;
    final theme = Theme.of(context);
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
              color: isSelected ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.3),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: isSelected ? 40 : 0,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookMosaic(List<Book> books) {
    return GridView.builder(
      key: const ValueKey('bookMosaic'),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookTile(book);
      },
    );
  }

  Widget _buildBookTile(Book book) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _selectedBook = book);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              book.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${book.chapterCount} CH',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterMosaic(Book book) {
    return Column(
      key: const ValueKey('chapterMosaic'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedBook = null),
                icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              Expanded(
                child: Text(
                  book.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: book.chapterCount,
            itemBuilder: (context, index) {
              final chapter = index + 1;
              return _buildChapterTile(chapter, book);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTile(int chapter, Book book) {
    final theme = Theme.of(context);
    final bible = Provider.of<BibleProvider>(context, listen: false);
    final isSelected = bible.currentBook?.id == book.id && bible.currentChapter == chapter;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        bible.loadChapter(book.id, chapter);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            '$chapter',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildReadingStats(BuildContext context, BibleProvider bible) {
    final theme = Theme.of(context);
    final stats = bible.readingStats;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withValues(alpha: 0.15), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, stats['chaptersRead'].toString(), 'READ', Icons.auto_stories),
            _buildStatItem(context, stats['totalBookmarks'].toString(), 'SAVED', Icons.bookmark),
            _buildStatItem(context, stats['totalHighlights'].toString(), 'HIGHLIGHTS', Icons.auto_awesome),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionDownloaderButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VersionsScreen()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_for_offline, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'DOWNLOAD VERSIONS',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
