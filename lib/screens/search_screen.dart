import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';
import '../widgets/verse_action_toolbar.dart';
import '../widgets/verse_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _submitted = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (value != null) {
      _controller.text = value;
      _controller.selection = TextSelection.collapsed(offset: value.length);
    }
    if (query.isEmpty) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() => _submitted = query);
    context.read<BibleProvider>().search(query);
  }

  void _clear() {
    _controller.clear();
    setState(() => _submitted = '');
    context.read<BibleProvider>().search('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bible = context.watch<BibleProvider>();
    final results = _submitted.isEmpty ? const [] : bible.searchResults;

    Widget body;
    if (bible.isLoading && _submitted.isNotEmpty) {
      body = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (_submitted.isEmpty) {
      body = _Hints(onPick: _search);
    } else if (results.isEmpty) {
      body = AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No verses found',
        subtitle: 'Nothing in ${bible.currentVersion?.shortName ?? 'this Bible'} '
            'matches “$_submitted”. Try a shorter word.',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        itemCount: results.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                '${results.length} ${results.length == 1 ? 'verse' : 'verses'}'
                ' in ${bible.currentVersion?.shortName ?? ''}',
                style: theme.textTheme.bodySmall,
              ),
            );
          }
          final verse = results[i - 1];
          return VerseTile(
            verse: verse,
            showHeader: true,
            onBookmarkToggle: () => bible.toggleBookmark(verse),
            onTap: () => VerseActionToolbar.show(context, verse, bible),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: _search,
            decoration: InputDecoration(
              hintText: 'Search the Bible',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: _clear,
                    ),
            ),
          ),
        ),
      ),
      body: AppColumn(maxWidth: 720, child: body),
    );
  }
}

class _Hints extends StatelessWidget {
  final ValueChanged<String> onPick;

  const _Hints({required this.onPick});

  static const _examples = ['love', 'peace', 'faith', 'light', 'shepherd'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(
          'Search for a word or phrase in the version you’re reading.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final word in _examples)
              AppPill(label: word, onTap: () => onPick(word)),
          ],
        ),
      ],
    );
  }
}
