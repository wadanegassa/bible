import '../../data/local_db/database_helper.dart';
import '../../data/models/bible_models.dart';

class DailyVerseRef {
  final String bookId;
  final int chapter;
  final int verse;

  const DailyVerseRef(this.bookId, this.chapter, this.verse);
}

class DailyVerseService {
  final DatabaseHelper _db = DatabaseHelper();

  static const List<DailyVerseRef> _refs = [
    DailyVerseRef('JHN', 3, 16),
    DailyVerseRef('PSA', 23, 1),
    DailyVerseRef('PHP', 4, 13),
    DailyVerseRef('ROM', 8, 28),
    DailyVerseRef('JER', 29, 11),
    DailyVerseRef('PRO', 3, 5),
    DailyVerseRef('ISA', 41, 10),
    DailyVerseRef('MAT', 6, 33),
    DailyVerseRef('JOS', 1, 9),
    DailyVerseRef('PSA', 46, 1),
    DailyVerseRef('2TI', 1, 7),
    DailyVerseRef('MAT', 11, 28),
    DailyVerseRef('PSA', 119, 105),
    DailyVerseRef('ROM', 12, 2),
    DailyVerseRef('GAL', 5, 22),
    DailyVerseRef('PSA', 91, 1),
    DailyVerseRef('JHN', 14, 6),
    DailyVerseRef('1CO', 13, 4),
    DailyVerseRef('HEB', 11, 1),
    DailyVerseRef('PSA', 27, 1),
    DailyVerseRef('MIC', 6, 8),
    DailyVerseRef('JHN', 1, 1),
    DailyVerseRef('ROM', 5, 8),
    DailyVerseRef('PSA', 100, 1),
    DailyVerseRef('EPH', 2, 8),
    DailyVerseRef('ISA', 40, 31),
    DailyVerseRef('MAT', 5, 9),
    DailyVerseRef('PSA', 121, 1),
    DailyVerseRef('JHN', 15, 5),
    DailyVerseRef('COL', 3, 23),
    DailyVerseRef('PSA', 34, 8),
  ];

  DailyVerseRef refForDate(DateTime date) {
    final index = date.difference(DateTime(date.year)).inDays % _refs.length;
    return _refs[index];
  }

  Future<Verse?> loadForTranslation(String translation, {DateTime? date}) async {
    final ref = refForDate(date ?? DateTime.now());
    final row = await _db.getVerseByRef(
      translation: translation,
      bookId: ref.bookId,
      chapter: ref.chapter,
      verse: ref.verse,
    );
    if (row == null) {
      // Fallback: first verse of Genesis if curated verse missing in this pack.
      final fallback = await _db.getVerseByRef(
        translation: translation,
        bookId: 'GEN',
        chapter: 1,
        verse: 1,
      );
      return fallback == null ? null : Verse.fromMap(fallback);
    }
    return Verse.fromMap(row);
  }
}
