import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bible_v6.db');
    return openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE translations (
        id TEXT PRIMARY KEY,
        language TEXT,
        language_name TEXT,
        dialect TEXT,
        name TEXT,
        short_name TEXT,
        publisher TEXT,
        year INTEGER,
        license_type TEXT,
        attribution TEXT,
        scope TEXT,
        book_count INTEGER,
        installed INTEGER DEFAULT 0,
        installed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        translation TEXT NOT NULL,
        book_id TEXT NOT NULL,
        name TEXT NOT NULL,
        name_long TEXT,
        testament TEXT NOT NULL,
        chapter_count INTEGER NOT NULL,
        book_order INTEGER NOT NULL,
        PRIMARY KEY (translation, book_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE verses (
        db_id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_bookmarked INTEGER DEFAULT 0,
        translation TEXT NOT NULL,
        highlight_color TEXT
      )
    ''');

    await _createEngagementTables(db);

    await db.execute(
      'CREATE INDEX idx_verses_lookup ON verses (translation, book_id, chapter)',
    );
    await db.execute(
      'CREATE INDEX idx_verses_search ON verses (translation, text)',
    );
    await db.execute(
      'CREATE INDEX idx_books_translation ON books (translation, book_order)',
    );
  }

  Future<void> _createEngagementTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        translation TEXT NOT NULL,
        book_id TEXT NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        note TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(translation, book_id, chapter, verse)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        translation TEXT NOT NULL,
        book_id TEXT NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        read_at INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_lookup ON notes (translation, updated_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_lookup ON reading_history (read_at DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS verses');
      await db.execute('DROP TABLE IF EXISTS books');
      await db.execute('DROP TABLE IF EXISTS translations');
      await _onCreate(db, newVersion);
      return;
    }
    if (oldVersion < 7) {
      await _createEngagementTables(db);
    }
  }

  Future<Set<String>> getInstalledTranslationIds() async {
    final db = await database;
    final rows = await db.query(
      'translations',
      columns: ['id'],
      where: 'installed = 1',
    );
    return rows.map((row) => row['id'] as String).toSet();
  }

  Future<bool> isTranslationInstalled(String translationId) async {
    final db = await database;
    final rows = await db.query(
      'translations',
      columns: ['id'],
      where: 'id = ? AND installed = 1',
      whereArgs: [translationId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> hasTranslationContent(String translationId) async {
    final counts = await translationContentCounts(translationId);
    return counts.books > 0 && counts.verses > 0;
  }

  Future<({int books, int verses})> translationContentCounts(
    String translationId,
  ) async {
    final db = await database;
    final books = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM books WHERE translation = ?',
      [translationId],
    );
    final verses = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM verses WHERE translation = ?',
      [translationId],
    );
    return (
      books: (books.first['c'] as int?) ?? 0,
      verses: (verses.first['c'] as int?) ?? 0,
    );
  }

  /// Sample verse used to detect a wrong-language pack install.
  Future<({String? bookName, String? text})> getSampleVerse(
    String translationId, {
    String bookId = 'GEN',
    int chapter = 1,
    int verse = 1,
  }) async {
    final db = await database;
    final bookRows = await db.query(
      'books',
      columns: ['name'],
      where: 'translation = ? AND book_id = ?',
      whereArgs: [translationId, bookId],
      limit: 1,
    );
    final verseRows = await db.query(
      'verses',
      columns: ['text', 'book_name'],
      where: 'translation = ? AND book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [translationId, bookId, chapter, verse],
      limit: 1,
    );
    final bookName = bookRows.isEmpty
        ? null
        : bookRows.first['name'] as String?;
    if (verseRows.isEmpty) {
      return (bookName: bookName, text: null);
    }
    return (
      bookName: bookName ?? verseRows.first['book_name'] as String?,
      text: verseRows.first['text'] as String?,
    );
  }

  Future<void> installTranslationPack(Map<String, dynamic> pack) async {
    final db = await database;
    final translationId = pack['id'] as String;
    final books = (pack['books'] as List).cast<Map<String, dynamic>>();

    await db.transaction((txn) async {
      await txn.delete('verses', where: 'translation = ?', whereArgs: [translationId]);
      await txn.delete('books', where: 'translation = ?', whereArgs: [translationId]);
      await txn.delete('translations', where: 'id = ?', whereArgs: [translationId]);

      final license = (pack['license'] as Map?)?.cast<String, dynamic>() ?? {};
      await txn.insert('translations', {
        'id': translationId,
        'language': pack['language'],
        'language_name': pack['languageName'],
        'dialect': pack['dialect'],
        'name': pack['name'],
        'short_name': pack['shortName'],
        'publisher': pack['publisher'],
        'year': pack['year'],
        'license_type': license['type'],
        'attribution': pack['attribution'],
        'scope': pack['scope'],
        'book_count': pack['bookCount'] ?? books.length,
        'installed': 1,
        'installed_at': DateTime.now().millisecondsSinceEpoch,
      });

      final verseBatch = txn.batch();
      final bookBatch = txn.batch();

      for (var i = 0; i < books.length; i++) {
        final book = books[i];
        final bookId = book['id'] as String;
        final bookName = book['name'] as String;
        final chapters = (book['chapters'] as List).cast<Map<String, dynamic>>();

        bookBatch.insert('books', {
          'translation': translationId,
          'book_id': bookId,
          'name': bookName,
          'name_long': book['nameLong'] ?? bookName,
          'testament': book['testament'] ?? 'old',
          'chapter_count': chapters.length,
          'book_order': i + 1,
        });

        for (final chapter in chapters) {
          final chapterNum = chapter['number'] as int;
          final verses = (chapter['verses'] as List).cast<Map<String, dynamic>>();
          for (final verse in verses) {
            verseBatch.insert('verses', {
              'book_id': bookId,
              'book_name': bookName,
              'chapter': chapterNum,
              'verse': verse['number'],
              'text': verse['text'] ?? '',
              'is_bookmarked': 0,
              'translation': translationId,
              'highlight_color': null,
            });
          }
        }
      }

      await bookBatch.commit(noResult: true);
      await verseBatch.commit(noResult: true);
    });
  }

  Future<void> uninstallTranslation(String translationId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('verses', where: 'translation = ?', whereArgs: [translationId]);
      await txn.delete('books', where: 'translation = ?', whereArgs: [translationId]);
      await txn.update(
        'translations',
        {'installed': 0},
        where: 'id = ?',
        whereArgs: [translationId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getBooks(String translation) async {
    final db = await database;
    return db.query(
      'books',
      where: 'translation = ?',
      whereArgs: [translation],
      orderBy: 'book_order ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getVerses(
    String bookId,
    int chapter, {
    required String translation,
  }) async {
    final db = await database;
    return db.query(
      'verses',
      where: 'book_id = ? AND chapter = ? AND translation = ?',
      whereArgs: [bookId, chapter, translation],
      orderBy: 'verse ASC',
    );
  }

  Future<void> toggleBookmark(int dbId, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'verses',
      {'is_bookmarked': isBookmarked ? 1 : 0},
      where: 'db_id = ?',
      whereArgs: [dbId],
    );
  }

  Future<void> updateHighlight(int dbId, String? color) async {
    final db = await database;
    await db.update(
      'verses',
      {'highlight_color': color},
      where: 'db_id = ?',
      whereArgs: [dbId],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarks({required String translation}) async {
    final db = await database;
    return db.query(
      'verses',
      where: 'is_bookmarked = 1 AND translation = ?',
      whereArgs: [translation],
    );
  }

  Future<List<Map<String, dynamic>>> searchVerses(
    String query, {
    required String translation,
  }) async {
    final db = await database;
    return db.query(
      'verses',
      where: 'text LIKE ? AND translation = ?',
      whereArgs: ['%$query%', translation],
      limit: 50,
    );
  }

  Future<List<Map<String, dynamic>>> getHighlights({required String translation}) async {
    final db = await database;
    return db.query(
      'verses',
      where: 'highlight_color IS NOT NULL AND translation = ?',
      whereArgs: [translation],
      orderBy: 'book_id ASC, chapter ASC, verse ASC',
    );
  }

  Future<Map<String, dynamic>?> getVerseByRef({
    required String translation,
    required String bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await database;
    final rows = await db.query(
      'verses',
      where: 'translation = ? AND book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [translation, bookId, chapter, verse],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertNote({
    required String translation,
    required String bookId,
    required String bookName,
    required int chapter,
    required int verse,
    required String note,
  }) async {
    final db = await database;
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      await db.delete(
        'notes',
        where: 'translation = ? AND book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [translation, bookId, chapter, verse],
      );
      return;
    }
    await db.insert(
      'notes',
      {
        'translation': translation,
        'book_id': bookId,
        'book_name': bookName,
        'chapter': chapter,
        'verse': verse,
        'note': trimmed,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getNote({
    required String translation,
    required String bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await database;
    final rows = await db.query(
      'notes',
      columns: ['note'],
      where: 'translation = ? AND book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [translation, bookId, chapter, verse],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['note'] as String?;
  }

  Future<List<Map<String, dynamic>>> getNotes({
    String? translation,
    String? query,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (translation != null) {
      where.add('translation = ?');
      args.add(translation);
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('(note LIKE ? OR book_name LIKE ?)');
      args.add('%${query.trim()}%');
      args.add('%${query.trim()}%');
    }
    return db.query(
      'notes',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> addHistory({
    required String translation,
    required String bookId,
    required String bookName,
    required int chapter,
  }) async {
    final db = await database;
    await db.insert('reading_history', {
      'translation': translation,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'read_at': DateTime.now().millisecondsSinceEpoch,
    });
    // Keep history lean.
    await db.rawDelete('''
      DELETE FROM reading_history
      WHERE id NOT IN (
        SELECT id FROM reading_history ORDER BY read_at DESC LIMIT 100
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getHistory({int limit = 30}) async {
    final db = await database;
    return db.query(
      'reading_history',
      orderBy: 'read_at DESC',
      limit: limit,
    );
  }
}
