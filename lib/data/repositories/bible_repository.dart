import '../models/bible_models.dart';
import '../local_db/database_helper.dart';
import '../api_service.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  // bible-api.com doesn't have a book list endpoint, so we use a static list
  final List<Book> _staticBooks = [
    Book(id: 'GEN', name: 'Genesis', chapterCount: 50, testament: Testament.oldTestament),
    Book(id: 'EXO', name: 'Exodus', chapterCount: 40, testament: Testament.oldTestament),
    Book(id: 'LEV', name: 'Leviticus', chapterCount: 27, testament: Testament.oldTestament),
    Book(id: 'NUM', name: 'Numbers', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'DEU', name: 'Deuteronomy', chapterCount: 34, testament: Testament.oldTestament),
    Book(id: 'JOS', name: 'Joshua', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'JDG', name: 'Judges', chapterCount: 21, testament: Testament.oldTestament),
    Book(id: 'RUT', name: 'Ruth', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: '1SA', name: '1 Samuel', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: '2SA', name: '2 Samuel', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: '1KI', name: '1 Kings', chapterCount: 22, testament: Testament.oldTestament),
    Book(id: '2KI', name: '2 Kings', chapterCount: 25, testament: Testament.oldTestament),
    Book(id: '1CH', name: '1 Chronicles', chapterCount: 29, testament: Testament.oldTestament),
    Book(id: '2CH', name: '2 Chronicles', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'EZR', name: 'Ezra', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'NEH', name: 'Nehemiah', chapterCount: 13, testament: Testament.oldTestament),
    Book(id: 'EST', name: 'Esther', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'JOB', name: 'Job', chapterCount: 42, testament: Testament.oldTestament),
    Book(id: 'PSA', name: 'Psalms', chapterCount: 150, testament: Testament.oldTestament),
    Book(id: 'PRO', name: 'Proverbs', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'ECC', name: 'Ecclesiastes', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'SNG', name: 'Song of Solomon', chapterCount: 8, testament: Testament.oldTestament),
    Book(id: 'ISA', name: 'Isaiah', chapterCount: 66, testament: Testament.oldTestament),
    Book(id: 'JER', name: 'Jeremiah', chapterCount: 52, testament: Testament.oldTestament),
    Book(id: 'LAM', name: 'Lamentations', chapterCount: 5, testament: Testament.oldTestament),
    Book(id: 'EZK', name: 'Ezekiel', chapterCount: 48, testament: Testament.oldTestament),
    Book(id: 'DAN', name: 'Daniel', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'HOS', name: 'Hosea', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'JOE', name: 'Joel', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'AMO', name: 'Amos', chapterCount: 9, testament: Testament.oldTestament),
    Book(id: 'OBA', name: 'Obadiah', chapterCount: 1, testament: Testament.oldTestament),
    Book(id: 'JON', name: 'Jonah', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'MIC', name: 'Micah', chapterCount: 7, testament: Testament.oldTestament),
    Book(id: 'NAM', name: 'Nahum', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'HAB', name: 'Habakkuk', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ZEP', name: 'Zephaniah', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'HAG', name: 'Haggai', chapterCount: 2, testament: Testament.oldTestament),
    Book(id: 'ZEC', name: 'Zechariah', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'MAL', name: 'Malachi', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'MAT', name: 'Matthew', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'MRK', name: 'Mark', chapterCount: 16, testament: Testament.newTestament),
    Book(id: 'LUK', name: 'Luke', chapterCount: 24, testament: Testament.newTestament),
    Book(id: 'JHN', name: 'John', chapterCount: 21, testament: Testament.newTestament),
    Book(id: 'ACT', name: 'Acts', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'ROM', name: 'Romans', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '1CO', name: '1 Corinthians', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '2CO', name: '2 Corinthians', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'GAL', name: 'Galatians', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'EPH', name: 'Ephesians', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'PHP', name: 'Philippians', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'COL', name: 'Colossians', chapterCount: 4, testament: Testament.newTestament),
    Book(id: '1TH', name: '1 Thessalonians', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2TH', name: '2 Thessalonians', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1TI', name: '1 Timothy', chapterCount: 6, testament: Testament.newTestament),
    Book(id: '2TI', name: '2 Timothy', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'TIT', name: 'Titus', chapterCount: 3, testament: Testament.newTestament),
    Book(id: 'PHM', name: 'Philemon', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'HEB', name: 'Hebrews', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'JAS', name: 'James', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '1PE', name: '1 Peter', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2PE', name: '2 Peter', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1JN', name: '1 John', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2JN', name: '2 John', chapterCount: 1, testament: Testament.newTestament),
    Book(id: '3JN', name: '3 John', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'JUD', name: 'Jude', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'REV', name: 'Revelation', chapterCount: 22, testament: Testament.newTestament),
  ];

  Future<List<Book>> getBooks() async {
    return _staticBooks;
  }

  Future<List<Verse>> getVerses(String bookId, int chapter) async {
    // 1. Check local cache
    final localData = await _dbHelper.getVerses(bookId, chapter);
    if (localData.isNotEmpty) {
      return localData.map((v) => Verse.fromMap(v)).toList();
    }

    // 2. Fetch from API
    try {
      final remoteVerses = await _apiService.getChapterContent(bookId, chapter);
      // 3. Cache
      for (var verse in remoteVerses) {
        await _dbHelper.insertVerse(verse.toMap());
      }
      return remoteVerses;
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleBookmark(Verse verse) async {
    await _dbHelper.toggleBookmark(verse.bookId, verse.chapter, verse.verse, !verse.isBookmarked);
  }

  Future<List<Verse>> getBookmarks() async {
    final data = await _dbHelper.getBookmarks();
    return data.map((v) => Verse.fromMap(v)).toList();
  }

  Future<List<Verse>> search(String query) async {
    final data = await _dbHelper.searchVerses(query);
    return data.map((v) => Verse.fromMap(v)).toList();
  }
}
