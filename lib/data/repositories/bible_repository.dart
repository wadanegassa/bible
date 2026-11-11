import '../local_db/database_helper.dart';
import '../models/bible_models.dart';
import '../models/bible_version_models.dart';
import '../services/bible_pack_service.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final BiblePackService _packService = BiblePackService();

  BibleCatalog? _catalog;

  Future<BibleCatalog> loadCatalog({bool forceReload = false}) async {
    if (_catalog != null && !forceReload) return _catalog!;
    _catalog = await _packService.loadCatalog();
    return _catalog!;
  }

  Future<BibleCatalog> ensureReady({String? preferredId}) async {
    final catalog = await loadCatalog(forceReload: true);
    await _packService.ensurePreferredInstalled(
      catalog,
      preferredId: preferredId,
    );
    _catalog = await loadCatalog(forceReload: true);
    return _catalog!;
  }

  Future<void> installVersion(BibleVersion version) async {
    await _packService.installVersion(version);
    _catalog = await loadCatalog(forceReload: true);
  }

  Future<void> uninstallVersion(BibleVersion version) async {
    await _packService.uninstallVersion(version);
    _catalog = await loadCatalog(forceReload: true);
  }

  Future<List<Book>> getBooks(String translation) async {
    final rows = await _dbHelper.getBooks(translation);
    return rows
        .map(
          (row) => Book(
            id: row['book_id'] as String,
            name: row['name'] as String,
            chapterCount: row['chapter_count'] as int,
            testament: Book.testamentFromString(row['testament']?.toString()),
          ),
        )
        .toList();
  }

  Future<List<Verse>> getVerses(
    String bookId,
    int chapter, {
    required String translation,
  }) async {
    final rows = await _dbHelper.getVerses(
      bookId,
      chapter,
      translation: translation,
    );
    return rows.map(Verse.fromMap).toList();
  }

  Future<void> toggleBookmark(Verse verse) async {
    await _dbHelper.toggleBookmark(verse.dbId!, !verse.isBookmarked);
  }

  Future<void> updateHighlight(Verse verse, String? color) async {
    await _dbHelper.updateHighlight(verse.dbId!, color);
  }

  Future<List<Verse>> search(String query, {required String translation}) async {
    final data = await _dbHelper.searchVerses(query, translation: translation);
    return data.map(Verse.fromMap).toList();
  }

  Future<List<Verse>> getBookmarks({required String translation}) async {
    final data = await _dbHelper.getBookmarks(translation: translation);
    return data.map(Verse.fromMap).toList();
  }

  Future<List<Verse>> getHighlights({required String translation}) async {
    final data = await _dbHelper.getHighlights(translation: translation);
    return data.map(Verse.fromMap).toList();
  }

  Future<Verse?> getVerseByRef({
    required String translation,
    required String bookId,
    required int chapter,
    required int verse,
  }) async {
    final row = await _dbHelper.getVerseByRef(
      translation: translation,
      bookId: bookId,
      chapter: chapter,
      verse: verse,
    );
    return row == null ? null : Verse.fromMap(row);
  }

  Future<void> upsertNote({
    required String translation,
    required String bookId,
    required String bookName,
    required int chapter,
    required int verse,
    required String note,
  }) async {
    await _dbHelper.upsertNote(
      translation: translation,
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      note: note,
    );
  }

  Future<String?> getNote({
    required String translation,
    required String bookId,
    required int chapter,
    required int verse,
  }) {
    return _dbHelper.getNote(
      translation: translation,
      bookId: bookId,
      chapter: chapter,
      verse: verse,
    );
  }

  Future<List<Map<String, dynamic>>> getNotes({
    String? translation,
    String? query,
  }) {
    return _dbHelper.getNotes(translation: translation, query: query);
  }

  Future<void> addHistory({
    required String translation,
    required String bookId,
    required String bookName,
    required int chapter,
  }) {
    return _dbHelper.addHistory(
      translation: translation,
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory({int limit = 30}) {
    return _dbHelper.getHistory(limit: limit);
  }
}
