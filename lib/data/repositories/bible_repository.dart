import 'dart:convert';
import 'package:flutter/services.dart';
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
    Book(id: 'RE', name: 'Revelation', chapterCount: 22, testament: Testament.newTestament),
  ];

  final List<Book> _oromoBooks = [
    Book(id: 'Uumama', name: 'Uumama', chapterCount: 50, testament: Testament.oldTestament),
    Book(id: 'Ba\'uu', name: 'Ba\'uu', chapterCount: 40, testament: Testament.oldTestament),
    Book(id: 'Lewwoota', name: 'Lewwoota', chapterCount: 27, testament: Testament.oldTestament),
    Book(id: 'Lakkoobsa', name: 'Lakkoobsa', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'Keessa Deebii', name: 'Keessa Deebii', chapterCount: 34, testament: Testament.oldTestament),
    Book(id: 'Iyaasuu', name: 'Iyaasuu', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'Abbaa Firdii', name: 'Abbaa Firdii', chapterCount: 21, testament: Testament.oldTestament),
    Book(id: 'Ruut', name: 'Ruut', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: '1 Saamu\'el', name: '1 Saamu\'el', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: '2 Saamu\'el', name: '2 Saamu\'el', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: '1 Mootota', name: '1 Mootota', chapterCount: 22, testament: Testament.oldTestament),
    Book(id: '2 Mootota', name: '2 Mootota', chapterCount: 25, testament: Testament.oldTestament),
    Book(id: '1 Seenaa', name: '1 Seenaa', chapterCount: 29, testament: Testament.oldTestament),
    Book(id: '2 Seenaa', name: '2 Seenaa', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'Izraa', name: 'Izraa', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'Nahimiiyaa', name: 'Nahimiiyaa', chapterCount: 13, testament: Testament.oldTestament),
    Book(id: 'Asteer', name: 'Asteer', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'Iyoob', name: 'Iyoob', chapterCount: 42, testament: Testament.oldTestament),
    Book(id: 'Faarfannaa', name: 'Faarfannaa', chapterCount: 150, testament: Testament.oldTestament),
    Book(id: 'Fakkeenya', name: 'Fakkeenya', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'Lallaba', name: 'Lallaba', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'Weedduu Solomoon', name: 'Weedduu Solomoon', chapterCount: 8, testament: Testament.oldTestament),
    Book(id: 'Isaayaas', name: 'Isaayaas', chapterCount: 66, testament: Testament.oldTestament),
    Book(id: 'Ermiyaas', name: 'Ermiyaas', chapterCount: 52, testament: Testament.oldTestament),
    Book(id: 'Faaruu Ermiyaas', name: 'Faaruu Ermiyaas', chapterCount: 5, testament: Testament.oldTestament),
    Book(id: 'Hisqi\'el', name: 'Hisqi\'el', chapterCount: 48, testament: Testament.oldTestament),
    Book(id: 'Daani\'el', name: 'Daani\'el', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'Hoose\'aa', name: 'Hoose\'aa', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'Yo\'el', name: 'Yo\'el', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'Amos', name: 'Amos', chapterCount: 9, testament: Testament.oldTestament),
    Book(id: 'Obaadiyaa', name: 'Obaadiyaa', chapterCount: 1, testament: Testament.oldTestament),
    Book(id: 'Yoonaas', name: 'Yoonaas', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'Miikiyaas', name: 'Miikiyaas', chapterCount: 7, testament: Testament.oldTestament),
    Book(id: 'Naahom', name: 'Naahom', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'Anbaaqom', name: 'Anbaaqom', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'Sefaaniyaa', name: 'Sefaaniyaa', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'Haagee', name: 'Haagee', chapterCount: 2, testament: Testament.oldTestament),
    Book(id: 'Zakaariyaas', name: 'Zakaariyaas', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'Miilkiyaas', name: 'Miilkiyaas', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'Maatewoos', name: 'Maatewoos', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'Maarqos', name: 'Maarqos', chapterCount: 16, testament: Testament.newTestament),
    Book(id: 'Luqaas', name: 'Luqaas', chapterCount: 24, testament: Testament.newTestament),
    Book(id: 'Yohaannis', name: 'Yohaannis', chapterCount: 21, testament: Testament.newTestament),
    Book(id: 'Hojii Ergamtootaa', name: 'Hojii Ergamtootaa', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'Roomaa', name: 'Roomaa', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '1 Qorontoos', name: '1 Qorontoos', chapterCount: 16, testament: Testament.newTestament),
    Book(id: '2 Qorontoos', name: '2 Qorontoos', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'Galaatiyaa', name: 'Galaatiyaa', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'Efesoon', name: 'Efesoon', chapterCount: 6, testament: Testament.newTestament),
    Book(id: 'Filiphisiiyus', name: 'Filiphisiiyus', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'Qoloosaayis', name: 'Qoloosaayis', chapterCount: 4, testament: Testament.newTestament),
    Book(id: '1 Tasaloonqee', name: '1 Tasaloonqee', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2 Tasaloonqee', name: '2 Tasaloonqee', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1 Ximootewoosi', name: '1 Ximootewoosi', chapterCount: 6, testament: Testament.newTestament),
    Book(id: '2 Ximootewoosi', name: '2 Ximootewoosi', chapterCount: 4, testament: Testament.newTestament),
    Book(id: 'Tiitoo', name: 'Tiitoo', chapterCount: 3, testament: Testament.newTestament),
    Book(id: 'Filmoonaa', name: 'Filmoonaa', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'Ibrootaa', name: 'Ibrootaa', chapterCount: 13, testament: Testament.newTestament),
    Book(id: 'Yaaqoob', name: 'Yaaqoob', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '1 Pheexiroos', name: '1 Pheexiroos', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2 Pheexiroos', name: '2 Pheexiroos', chapterCount: 3, testament: Testament.newTestament),
    Book(id: '1 Yohaannis', name: '1 Yohaannis', chapterCount: 5, testament: Testament.newTestament),
    Book(id: '2 Yohaannis', name: '2 Yohaannis', chapterCount: 1, testament: Testament.newTestament),
    Book(id: '3 Yohaannis', name: '3 Yohaannis', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'Yihuudaa', name: 'Yihuudaa', chapterCount: 1, testament: Testament.newTestament),
    Book(id: 'Mul\'ata Yohaannis', name: 'Mul\'ata Yohaannis', chapterCount: 22, testament: Testament.newTestament),
  ];

  List<Book> getBooks(String translation) {
    if (translation.contains('AMHARIC') || translation == 'NASV') {
      return _amharicBooks;
    }
    if (translation == 'MACQUL') {
      return _oromoBooks;
    }
    return _englishBooks;
  }

  Future<void> ensureInitialized({String translation = 'KJV'}) async {
    final isPopulated = await _dbHelper.isTranslationPopulated(translation);
    if (!isPopulated) {
      if (translation == 'KJV') {
        final jsonString = await rootBundle.loadString('assets/data/bible_en_kjv.json');
        final List<dynamic> data = json.decode(jsonString);
        await _dbHelper.prepopulate(data, translation);
      } else if (translation == 'AMHARIC_1962') {
        final jsonString = await rootBundle.loadString('assets/data/bible_am_full.json');
        final data = json.decode(jsonString);
        await _dbHelper.prepopulate(data['books'], translation);
      } else if (translation == 'NASV' || translation == 'MACQUL') {
        // These will be integrated via download logic or added later
        // For now, they share the same logic structure but need their own assets/APIs
        debugPrint('Initialization for $translation pending actual dataset integration');
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
