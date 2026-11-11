import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';
import '../widgets/app_surface.dart';
import '../widgets/verse_action_toolbar.dart';

class SavedScreen extends StatefulWidget {
  final VoidCallback? onOpenReader;

  const SavedScreen({super.key, this.onOpenReader});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _noteQuery = TextEditingController();

  @override
  void dispose() {
    _noteQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              Tab(text: _count('Bookmarks', bible.bookmarks.length)),
              Tab(text: _count('Highlights', bible.highlights.length)),
              Tab(text: _count('Notes', bible.notes.length)),
            ],
          ),
        ),
        body: AppColumn(
          child: TabBarView(
            children: [
              _VerseList(
                verses: bible.bookmarks,
                bible: bible,
                onOpenReader: widget.onOpenReader,
                empty: const AppEmptyState(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'No bookmarks yet',
                  subtitle: 'Tap any verse while reading and choose Save.',
                ),
              ),
              _VerseList(
                verses: bible.highlights,
                bible: bible,
                onOpenReader: widget.onOpenReader,
                empty: const AppEmptyState(
                  icon: Icons.border_color_outlined,
                  title: 'No highlights yet',
                  subtitle: 'Tap a verse and pick a colour to mark it.',
                ),
              ),
              _NotesList(
                bible: bible,
                controller: _noteQuery,
                onOpenReader: widget.onOpenReader,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _count(String label, int n) => n == 0 ? label : '$label  $n';
}

Color? _parseHighlight(String? raw) {
  if (raw == null) return null;
  try {
    return Color(int.parse('0x${raw.replaceAll('#', '')}'));
  } catch (_) {
    return null;
  }
}

class _VerseList extends StatelessWidget {
  final List<Verse> verses;
  final BibleProvider bible;
  final VoidCallback? onOpenReader;
  final Widget empty;

  const _VerseList({
    required this.verses,
    required this.bible,
    required this.onOpenReader,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return empty;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: verses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final verse = verses[i];
        final mark = _parseHighlight(verse.highlightColor);
        return AppSurface(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
          onTap: () async {
            await bible.loadChapter(verse.bookId, verse.chapter);
            onOpenReader?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (mark != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: mark, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      verse.reference,
                      style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Options',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.more_horiz_rounded, color: scheme.onSurfaceVariant),
                    onPressed: () => VerseActionToolbar.show(context, verse, bible),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  cleanVerseText(verse.text),
                  style: AppTheme.serif(fontSize: 17, height: 1.6, color: scheme.onSurface),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotesList extends StatelessWidget {
  final BibleProvider bible;
  final TextEditingController controller;
  final VoidCallback? onOpenReader;

  const _NotesList({
    required this.bible,
    required this.controller,
    required this.onOpenReader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notes = bible.notes;
    final searching = controller.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: TextField(
            controller: controller,
            onChanged: (q) => bible.loadNotes(query: q),
            decoration: const InputDecoration(
              hintText: 'Search your notes',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
            ),
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? AppEmptyState(
                  icon: Icons.edit_note_rounded,
                  title: searching ? 'No notes match' : 'No notes yet',
                  subtitle: searching
                      ? 'Try a different word.'
                      : 'Tap a verse and choose Note to write a reflection.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final note = notes[i];
                    final book = note['book_name'] as String? ?? '';
                    final chapter = note['chapter'] as int? ?? 0;
                    final verse = note['verse'] as int? ?? 0;
                    return AppSurface(
                      onTap: () async {
                        await bible.loadChapter(note['book_id'] as String? ?? '', chapter);
                        onOpenReader?.call();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$book $chapter:$verse',
                            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note['note'] as String? ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
