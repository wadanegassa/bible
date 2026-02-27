import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/verse_tile.dart';
import '../widgets/verse_action_toolbar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    if (_controller.text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<BibleProvider>().search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _controller,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Search (e.g., Jesus, John 3:16)',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 20, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      _controller.clear();
                      context.read<BibleProvider>().search('');
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _onSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.isInitializing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    bible.loadingMessage ?? 'Preparing Bible database...',
                    style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            );
          }

          if (bible.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = bible.searchResults;

          if (results.isEmpty && !bible.isLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _controller.text.isEmpty
                          ? 'Enter a word to search'
                          : 'No results found',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final verse = results[index];
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
