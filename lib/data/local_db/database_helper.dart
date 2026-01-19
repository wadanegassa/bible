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
    String path = join(await getDatabasesPath(), 'bible_v3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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
        UNIQUE(book_id, chapter, verse)
      )
    ''');

    await db.execute('CREATE INDEX idx_verses_lookup ON verses (book_id, chapter)');
  }

  Future<void> insertVerse(Map<String, dynamic> verse) async {
    final db = await database;
    await db.insert('verses', verse, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getVerses(String bookId, int chapter) async {
    final db = await database;
    return await db.query(
      'verses',
      where: 'book_id = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
    );
  }

  Future<void> toggleBookmark(String bookId, int chapter, int verse, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'verses',
      {'is_bookmarked': isBookmarked ? 1 : 0},
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('verses', where: 'is_bookmarked = 1');
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final db = await database;
    return await db.query(
      'verses',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
    );
  }
}
