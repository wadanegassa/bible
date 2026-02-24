import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/verse_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    if (_controller.text.isEmpty) return;
    context.read<BibleProvider>().search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search (e.g., Jesus, John 3:16)',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _controller.clear();
                      context.read<BibleProvider>().search('');
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _onSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = bible.searchResults;

          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _controller.text.isEmpty
                          ? 'Enter a word to search'
                          : 'No results found',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final verse = results[index];
              return VerseTile(
                verse: verse,
                showHeader: true,
                onBookmarkToggle: () => bible.toggleBookmark(verse),
              );
            },
          );
        },
      ),
    );
  }
}
