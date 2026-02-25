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

  final List<Book> _amharicBooks = [
    Book(id: 'ኦሪት ዘፍጥረት', name: 'ኦሪት ዘፍጥረት', chapterCount: 50, testament: Testament.oldTestament),
    Book(id: 'ኦሪት ዘጸአት', name: 'ኦሪት ዘጸአት', chapterCount: 40, testament: Testament.oldTestament),
    Book(id: 'ኦሪት ዘሌዋውያን', name: 'ኦሪት ዘሌዋውያን', chapterCount: 27, testament: Testament.oldTestament),
    Book(id: 'ኦሪት ዘኍልቍ', name: 'ኦሪት ዘኍልቍ', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'ኦሪት ዘዳግም', name: 'ኦሪት ዘዳግም', chapterCount: 34, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ኢያሱ ወልደ ነዌ', name: 'መጽሐፈ ኢያሱ ወልደ ነዌ', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ መሣፍንት', name: 'መጽሐፈ መሣፍንት', chapterCount: 21, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ሩት', name: 'መጽሐፈ ሩት', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ሳሙኤል ቀዳማዊ', name: 'መጽሐፈ ሳሙኤል ቀዳማዊ', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ሳሙኤል ካልዕ', name: 'መጽሐፈ ሳሙኤል ካልዕ', chapterCount: 24, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ነገሥት ቀዳማዊ', name: 'መጽሐፈ ነገሥት ቀዳማዊ', chapterCount: 22, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ነገሥት ካልዕ', name: 'መጽሐፈ ነገሥት ካልዕ', chapterCount: 25, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ዜና መዋዕል ቀዳማዊ', name: 'መጽሐፈ ዜና መዋዕል ቀዳማዊ', chapterCount: 29, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ዜና መዋዕል ካልዕ', name: 'መጽሐፈ ዜና መዋዕል ካልዕ', chapterCount: 36, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ዕዝራ', name: 'መጽሐፈ ዕዝራ', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ነህምያ', name: 'መጽሐፈ ነህምያ', chapterCount: 13, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ አስቴር', name: 'መጽሐፈ አስቴር', chapterCount: 10, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ኢዮብ', name: 'መጽሐፈ ኢዮብ', chapterCount: 42, testament: Testament.oldTestament),
    Book(id: 'መዝሙረ ዳዊት', name: 'መዝሙረ ዳዊት', chapterCount: 150, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ ምሳሌ', name: 'መጽሐፈ ምሳሌ', chapterCount: 31, testament: Testament.oldTestament),
    Book(id: 'መጽሐፈ መክብብ', name: 'መጽሐፈ መክብብ', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'መኃልየ መኃልይ ዘሰሎሞን', name: 'መኃልየ መኃልይ ዘሰሎሞን', chapterCount: 8, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ኢሳይያስ', name: 'ትንቢተ ኢሳይያስ', chapterCount: 66, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ኤርምያስ', name: 'ትንቢተ ኤርምያስ', chapterCount: 52, testament: Testament.oldTestament),
    Book(id: 'ሰቆቃወ ኤርምያስ', name: 'ሰቆቃወ ኤርምያስ', chapterCount: 5, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሕዝቅኤል', name: 'ትንቢተ ሕዝቅኤል', chapterCount: 48, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ዳንኤል', name: 'ትንቢተ ዳንኤል', chapterCount: 12, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሆሴዕ', name: 'ትንቢተ ሆሴዕ', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ኢዩኤል', name: 'ትንቢተ ኢዩኤል', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ አሞጽ', name: 'ትንቢተ አሞጽ', chapterCount: 9, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ አብድዩ', name: 'ትንቢተ አብድዩ', chapterCount: 1, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ዮናስ', name: 'ትንቢተ ዮናስ', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሚክያስ', name: 'ትንቢተ ሚክያስ', chapterCount: 7, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ናሆም', name: 'ትንቢተ ናሆም', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ዕንባቆም', name: 'ትንቢተ ዕንባቆም', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሶፎንያስ', name: 'ትንቢተ ሶፎንያስ', chapterCount: 3, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሐጌ', name: 'ትንቢተ ሐጌ', chapterCount: 2, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ዘካርያስ', name: 'ትንቢተ ዘካርያስ', chapterCount: 14, testament: Testament.oldTestament),
    Book(id: 'ትንቢተ ሚልክያስ', name: 'ትንቢተ ሚልክያስ', chapterCount: 4, testament: Testament.oldTestament),
    Book(id: 'የማቴዎስ ወንጌል', name: 'የማቴዎስ ወንጌል', chapterCount: 28, testament: Testament.newTestament),
    Book(id: 'የማርቆስ ወንጌል', name: 'የማርቆስ ወንጌል', chapterCount: 16, testament: Testament.newTestament),
    Book(id: 'የሉቃስ ወንጌል', name: 'የሉቃስ ወንጌል', chapterCount: 24, testament: Testament.newTestament),
    Book(id: 'የዮሐንስ ወንጌል', name: 'የዮሐንስ ወንጌል', chapterCount: 21, testament: Testament.newTestament),
    Book(id: 'የሐዋርያት ሥራ', name: 'የሐዋርያት ሥራ', chapterCount: 28, testament: Testament.newTestament),
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
    if (translation == 'AMHARIC') return _amharicBooks;
    return _englishBooks;
  }

  Future<void> ensureInitialized({String translation = 'KJV'}) async {
    final isPopulated = await _dbHelper.isTranslationPopulated(translation);
    if (!isPopulated) {
      if (translation == 'KJV') {
        final jsonString = await rootBundle.loadString('assets/data/bible_en_kjv.json');
        final List<dynamic> data = json.decode(jsonString);
        await _dbHelper.prepopulate(data, 'KJV');
      } else if (translation == 'AMHARIC') {
        final jsonString = await rootBundle.loadString('assets/data/bible_am_full.json');
        final data = json.decode(jsonString);
        await _dbHelper.prepopulate(data['books'], 'AMHARIC');
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
