import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../providers/bookmark_provider.dart';
import '../data/models/bible_models.dart';
import '../widgets/verse_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Verse> _results = [];
  bool _isSearching = false;

  void _onSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isSearching = true);
    final results = await context.read<BibleProvider>().search(_controller.text);
    setState(() {
      _results = results;
      _isSearching = false;
    });
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
                      setState(() => _results = []);
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
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
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
                              ? 'Enter a word or reference to search'
                              : 'No results found',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tip: Use references like "John 3:16" for precise results, or simple words to search your downloaded chapters.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final verse = _results[index];
                    return VerseTile(
                      verse: verse,
                      showHeader: true,
                      onBookmarkToggle: () {
                        context.read<BookmarkProvider>().toggleBookmark(verse);
                        setState(() {
                          final index = _results.indexOf(verse);
                          if (index != -1) {
                            _results[index] = verse.copyWith(isBookmarked: !verse.isBookmarked);
                          }
                        });
                      },
                    );
                  },
                ),
    );
  }
}
