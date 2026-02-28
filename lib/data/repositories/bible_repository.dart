import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/bible_models.dart';
import '../local_db/database_helper.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<Book> _englishBooks = [
    Book(id: 'GN', name: 'Genesis', chapterCount: 50, testament: Testament.oldTestament),
    Book(id: 'EX', name: 'Exodus', chapterCount: 40, testament: Testament.oldTestament),
    Book(id: 'LV', name: 'Leviticus', chapterCount: 27, testament: Testament.oldTestament),
    Book(id: 'NM', name: 'Numbers', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'DT', name: 'Deuteronomy', chapterCount: 34, testament: Testament.oldTestament),
    Book(id: 'JS', name: 'Joshua', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'JUD', name: 'Judges', chapterCount: 21, testament: Testament.oldTestament),
    Book(id: 'RT', name: 'Ruth', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: '1SM', name: '1 Samuel', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: '2SM', name: '2 Samuel', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: '1KGS', name: '1 Kings', chapterCount: 22, testament: Testament.oldTestament),
    Book(id: '2KGS', name: '2 Kings', chapterCount: 25, testament: Testament.oldTestament),
    Book(id: '1CH', name: '1 Chronicles', chapterCount: 29, testament: Testament.oldTestament),
    Book(id: '2CH', name: '2 Chronicles', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'EZR', name: 'Ezra', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'NE', name: 'Nehemiah', chapterCount: 13, testament: Testament.oldTestament),
    Book(id: 'ET', name: 'Esther', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'JOB', name: 'Job', chapterCount: 42, testament: Testament.oldTestament),
    Book(id: 'PS', name: 'Psalms', chapterCount: 150, testament: Testament.oldTestament),
    Book(id: 'PRV', name: 'Proverbs', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'EC', name: 'Ecclesiastes', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'SO', name: 'Song of Solomon', chapterCount: 8, testament: Testament.oldTestament),
    Book(id: 'IS', name: 'Isaiah', chapterCount: 66, testament: Testament.oldTestament),
    Book(id: 'JR', name: 'Jeremiah', chapterCount: 52, testament: Testament.oldTestament),
    Book(id: 'LM', name: 'Lamentations', chapterCount: 5, testament: Testament.oldTestament),
    Book(id: 'EZ', name: 'Ezekiel', chapterCount: 48, testament: Testament.oldTestament),
    Book(id: 'DN', name: 'Daniel', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'HO', name: 'Hosea', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'JL', name: 'Joel', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'AM', name: 'Amos', chapterCount: 9, testament: Testament.oldTestament),
    Book(id: 'OB', name: 'Obadiah', chapterCount: 1, testament: Testament.oldTestament),
    Book(id: 'JN', name: 'Jonah', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'MI', name: 'Micah', chapterCount: 7, testament: Testament.oldTestament),
    Book(id: 'NA', name: 'Nahum', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'HK', name: 'Habakkuk', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ZP', name: 'Zephaniah', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'HG', name: 'Haggai', chapterCount: 2, testament: Testament.oldTestament),
    Book(id: 'ZC', name: 'Zechariah', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'ML', name: 'Malachi', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'MT', name: 'Matthew', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'MK', name: 'Mark', chapterCount: 16, testament: Testament.newTestament),
    Book(id: 'LK', name: 'Luke', chapterCount: 24, testament: Testament.newTestament),
    Book(id: 'JO', name: 'John', chapterCount: 21, testament: Testament.newTestament),
    Book(id: 'ACT', name: 'Acts', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'RM', name: 'Romans', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '1CO', name: '1 Corinthians', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '2CO', name: '2 Corinthians', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'GL', name: 'Galatians', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'EPH', name: 'Ephesians', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'PH', name: 'Philippians', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'CL', name: 'Colossians', chapterCount: 4, testament: Testament.newTestament),
    Book(id: '1TS', name: '1 Thessalonians', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2TS', name: '2 Thessalonians', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1TM', name: '1 Timothy', chapterCount: 6, testament: Testament.newTestament),
    Book(id: '2TM', name: '2 Timothy', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'TT', name: 'Titus', chapterCount: 3, testament: Testament.newTestament),
    Book(id: 'PHM', name: 'Philemon', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'HB', name: 'Hebrews', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'JM', name: 'James', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '1PE', name: '1 Peter', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2PE', name: '2 Peter', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1JO', name: '1 John', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2JO', name: '2 John', chapterCount: 1, testament: Testament.newTestament),
    Book(id: '3JO', name: '3 John', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'JD', name: 'Jude', chapterCount: 1, testament: Testament.newTestament),
  ];

  final List<Book> _amharicBooks = [
    Book(id: 'ዘፍጥረት', name: 'ዘፍጥረት', chapterCount: 50, testament: Testament.oldTestament),
    Book(id: 'ዘጸአት', name: 'ዘጸአት', chapterCount: 40, testament: Testament.oldTestament),
    Book(id: 'ዘሌዋውያን', name: 'ዘሌዋውያን', chapterCount: 27, testament: Testament.oldTestament),
    Book(id: 'ዘኍልኍ', name: 'ዘኍል', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'ዘዳግም', name: 'ዘዳግም', chapterCount: 34, testament: Testament.oldTestament),
    Book(id: 'ኢያሱ', name: 'ኢያሱ', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'መሣፍንት', name: 'መሣፍንት', chapterCount: 21, testament: Testament.oldTestament),
    Book(id: 'ሩት', name: 'ሩት', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'ሳሙኤል ቀዳማዊ', name: 'ሳሙኤል ቀዳማዊ', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'ሳሙኤል ካልዕ', name: 'ሳሙኤል ካልዕ', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'ነገሥት ቀዳማዊ', name: 'ነገሥት ቀዳማዊ', chapterCount: 22, testament: Testament.oldTestament),
    Book(id: 'ነገሥት ካልዕ', name: 'ነገሥት ካልዕ', chapterCount: 25, testament: Testament.oldTestament),
    Book(id: 'ዜና መዋዕል ቀዳማዊ', name: 'ዜና መዋዕል ቀዳማዊ', chapterCount: 29, testament: Testament.oldTestament),
    Book(id: 'ዜና መዋዕል ካልዕ', name: 'ዜና መዋዕል ካልዕ', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'ዕዝራ', name: 'ዕዝራ', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'ነህምያ', name: 'ነህምያ', chapterCount: 13, testament: Testament.oldTestament),
    Book(id: 'አስቴር', name: 'አስቴር', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'ኢዮብ', name: 'ኢዮብ', chapterCount: 42, testament: Testament.oldTestament),
    Book(id: 'መዝሙረ ዳዊት', name: 'መዝሙረ ዳዊት', chapterCount: 150, testament: Testament.oldTestament),
    Book(id: 'ምሳሌ', name: 'ምሳሌ', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'መክብብ', name: 'መክብብ', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'መኃልየ መኃልይ ዘሰሎሞን', name: 'መኃልየ መኃልይ ዘሰሎሞን', chapterCount: 8, testament: Testament.oldTestament),
    Book(id: 'ኢሳይያስ', name: 'ኢሳይያስ', chapterCount: 66, testament: Testament.oldTestament),
    Book(id: 'ኤርምያስ', name: 'ኤርምያስ', chapterCount: 52, testament: Testament.oldTestament),
    Book(id: 'ሰቆቃወ ኤርምያስ', name: 'ሰቆቃወ ኤርምያስ', chapterCount: 5, testament: Testament.oldTestament),
    Book(id: 'ሕዝቅኤል', name: 'ሕዝቅኤል', chapterCount: 48, testament: Testament.oldTestament),
    Book(id: 'ዳንኤል', name: 'ዳንኤል', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'ሆሴዕ', name: 'ሆሴዕ', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'ኢዩኤል', name: 'ኢዩኤል', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'አሞጽ', name: 'አሞጽ', chapterCount: 9, testament: Testament.oldTestament),
    Book(id: 'አብድዩ', name: 'አብድዩ', chapterCount: 1, testament: Testament.oldTestament),
    Book(id: 'ዮናስ', name: 'ዮናስ', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'ሚክያስ', name: 'ሚክያስ', chapterCount: 7, testament: Testament.oldTestament),
    Book(id: 'ናሆም', name: 'ናሆም', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ዕንባቆም', name: 'ዕንባቆም', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ሶፎንያስ', name: 'ሶፎንያስ', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ሐጌ', name: 'ሐጌ', chapterCount: 2, testament: Testament.oldTestament),
    Book(id: 'ዘካርያስ', name: 'ዘካርያስ', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'ሚልክያስ', name: 'ሚልክያስ', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'ማቴዎስ', name: 'ማቴዎስ', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'ማርቆስ', name: 'ማርቆስ', chapterCount: 16, testament: Testament.newTestament),
    Book(id: 'ሉቃስ', name: 'ሉቃስ', chapterCount: 24, testament: Testament.newTestament),
    Book(id: 'ዮሐንስ', name: 'ዮሐንስ', chapterCount: 21, testament: Testament.newTestament),
    Book(id: 'ሐዋርያት', name: 'ሐዋርያት', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'ወደ ሮሜ ሰዎች', name: 'ወደ ሮሜ ሰዎች', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '1ኛ ወደ ቆሮንቶስ ሰዎች', name: '1ኛ ወደ ቆሮንቶስ ሰዎች', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '2ኛ ወደ ቆሮንቶስ ሰዎች', name: '2ኛ ወደ ቆሮንቶስ ሰዎች', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'ወደ ገላትያ ሰዎች', name: 'ወደ ገላትያ ሰዎች', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'ወደ ኤፌሶን ሰዎች', name: 'ወደ ኤፌሶን ሰዎች', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'ወደ ፊልጵስዩስ ሰዎች', name: 'ወደ ፊልጵስዩስ ሰዎች', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'ወደ ቆላስይስ ሰዎች', name: 'ወደ ቆላስይስ ሰዎች', chapterCount: 4, testament: Testament.newTestament),
    Book(id: '1ኛ ወደ ተሰሎንቄ ሰዎች', name: '1ኛ ወደ ተሰሎንቄ ሰዎች', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2ኛ ወደ ተሰሎንቄ ሰዎች', name: '2ኛ ወደ ተሰሎንቄ ሰዎች', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1ኛ ወደ ጢሞቴዎስ', name: '1ኛ ወደ ጢሞቴዎስ', chapterCount: 6, testament: Testament.newTestament),
    Book(id: '2ኛ ወደ ጢሞቴዎስ', name: '2ኛ ወደ ጢሞቴዎስ', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'ወደ ቲቶ', name: 'ወደ ቲቶ', chapterCount: 3, testament: Testament.newTestament),
    Book(id: 'ወደ ፊልሞና', name: 'ወደ ፊልሞና', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'ወደ ዕብራውያን', name: 'ወደ ዕብራውያን', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'የያዕቆብ መልእክት', name: 'የያዕቆብ መልእክት', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '1ኛ የጴጥሮስ መልእክት', name: '1ኛ የጴጥሮስ መልእክት', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2ኛ የጴጥሮስ መልእክት', name: '2ኛ የጴጥሮስ መልእክት', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1ኛ የዮሐንስ መልእክት', name: '1ኛ የዮሐንስ መልእክት', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2ኛ የዮሐንስ መልእክት', name: '2ኛ የዮሐንስ መልእክት', chapterCount: 1, testament: Testament.newTestament),
    Book(id: '3ኛ የዮሐንስ መልእክት', name: '3ኛ የዮሐንስ መልእክት', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'የይሁዳ መልእክት', name: 'የይሁዳ መልእክት', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'የዮሐንስ ራእይ', name: 'የዮሐንስ ራእይ', chapterCount: 22, testament: Testament.newTestament),
  ];

  List<Book> getBooks(String translation) {
    if (translation.contains('AMHARIC')) {
      return _amharicBooks;
    }
    return _englishBooks;
  }

  static List<dynamic> _parseKjv(String jsonString) => json.decode(jsonString);
  static List<dynamic> _parseAmharic(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return data['books'] as List<dynamic>;
  }

  Future<void> ensureInitialized({String translation = 'KJV'}) async {
    final isPopulated = await _dbHelper.isTranslationPopulated(translation);
    if (!isPopulated) {
      if (translation == 'KJV') {
        final jsonString =
            await rootBundle.loadString('assets/data/bible_en_kjv.json');
        final List<dynamic> data = await compute(_parseKjv, jsonString);
        await _dbHelper.prepopulate(data, translation);
      } else if (translation == 'AMHARIC_1962') {
        final jsonString =
            await rootBundle.loadString('assets/data/bible_am_full.json');
        final List<dynamic> data = await compute(_parseAmharic, jsonString);
        await _dbHelper.prepopulate(data, translation);
      }
    }
  }

  Future<List<Verse>> getVerses(String bookId, int chapter, {String translation = 'KJV'}) async {
    final localData = await _dbHelper.getVerses(bookId, chapter, translation: translation);
    return localData.map((v) => Verse.fromMap(v)).toList();
  }

  Future<void> toggleBookmark(Verse verse) async {
    await _dbHelper.toggleBookmark(verse.dbId!, !verse.isBookmarked);
  }

  Future<void> updateHighlight(Verse verse, String? color) async {
    await _dbHelper.updateHighlight(verse.dbId!, color);
  }

  Future<List<Verse>> search(String query, {String translation = 'KJV'}) async {
    final data = await _dbHelper.searchVerses(query, translation: translation);
    return data.map((v) => Verse.fromMap(v)).toList();
  }

  Future<List<Verse>> getBookmarks({String translation = 'KJV'}) async {
    final data = await _dbHelper.getBookmarks(translation: translation);
    return data.map((v) => Verse.fromMap(v)).toList();
  }
}
