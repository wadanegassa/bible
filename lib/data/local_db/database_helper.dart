import 'dart:async';
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
    String path = join(await getDatabasesPath(), 'bible_v4.db'); // Use v4 to force fresh start if needed, or version bump
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE verses (
        db_id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT,
        is_bookmarked INTEGER DEFAULT 0,
        translation TEXT DEFAULT 'KJV',
        highlight_color TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_verses_lookup ON verses (book_id, chapter, translation)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ensure translation column exists
      try {
        await db.execute('ALTER TABLE verses ADD COLUMN translation TEXT DEFAULT "KJV"');
      } catch (e) {
        // Column might already exist
      }
      await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_lookup_v2 ON verses (book_id, chapter, translation)');
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE verses ADD COLUMN highlight_color TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 4) {
      // Any additional v4 changes
    }
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

  Future<void> insertVerse(Map<String, dynamic> verse) async {
    final db = await database;
    await db.insert('verses', verse, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getVerses(String bookId, int chapter, {String translation = 'KJV'}) async {
    final db = await database;
    return await db.query(
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

  Future<List<Map<String, dynamic>>> getBookmarks({String translation = 'KJV'}) async {
    final db = await database;
    return await db.query(
      'verses', 
      where: 'is_bookmarked = 1 AND translation = ?', 
      whereArgs: [translation]
    );
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query, {String translation = 'KJV'}) async {
    final db = await database;
    return await db.query(
      'verses',
      where: 'text LIKE ? AND translation = ?',
      whereArgs: ['%$query%', translation],
      limit: 50,
    );
  }

  Future<bool> isTranslationPopulated(String translation) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM verses WHERE translation = ? LIMIT 1',
      [translation],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('verses');
  }

  Future<void> prepopulate(List<dynamic> data, String translation) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      if (translation == 'KJV') {
        for (var book in data) {
          final bookName = book['name'];
          final abbrev = book['abbrev'] as String;
          final chapters = book['chapters'] as List<dynamic>;
          
          for (int cIndex = 0; cIndex < chapters.length; cIndex++) {
            final chapterNum = cIndex + 1;
            final verses = chapters[cIndex] as List<dynamic>;
            
            for (int vIndex = 0; vIndex < verses.length; vIndex++) {
              batch.insert('verses', {
                'book_id': abbrev.toUpperCase(),
                'book_name': bookName,
                'chapter': chapterNum,
                'verse': vIndex + 1,
                'text': verses[vIndex].toString().trim(),
                'is_bookmarked': 0,
                'translation': translation,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      } else if (translation == 'AMHARIC_1962' || 
                 translation == 'NASV' ||
                 translation == 'MACQUL') {
        final books = data;
        for (var book in books) {
          String rawBookName = book['title'].toString().trim();
          if (rawBookName.endsWith('።')) {
            rawBookName = rawBookName.substring(0, rawBookName.length - 1);
          }
          final String bookName = rawBookName.trim();
          final chapters = book['chapters'] as List<dynamic>;
          
          for (var chapterData in chapters) {
            final chapterNum = int.tryParse(chapterData['chapter'].toString()) ?? 0;
            final verses = chapterData['verses'] as List<dynamic>;
            
            for (int i = 0; i < verses.length; i++) {
              batch.insert('verses', {
                'book_id': bookName,
                'book_name': bookName,
                'chapter': chapterNum,
                'verse': i + 1,
                'text': verses[i].toString().trim(),
                'is_bookmarked': 0,
                'translation': translation,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
      await batch.commit(noResult: true);
    });
  }
}
