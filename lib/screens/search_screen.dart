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
          decoration: const InputDecoration(
            hintText: 'Search for a word...',
            border: InputBorder.none,
          ),
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
              ? const Center(child: Text('No results found.'))
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
                        _onSearch();
                      },
                    );
                  },
                ),
    );
  }
}
