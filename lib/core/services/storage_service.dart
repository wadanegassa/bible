import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyTranslation = 'last_translation';
  static const String _keyBookId = 'last_book_id';
  static const String _keyChapter = 'last_chapter';

  Future<void> saveSession(String translation, String bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTranslation, translation);
    await prefs.setString(_keyBookId, bookId);
    await prefs.setInt(_keyChapter, chapter);
  }

  Future<Map<String, dynamic>> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'translation': prefs.getString(_keyTranslation),
      'bookId': prefs.getString(_keyBookId),
      'chapter': prefs.getInt(_keyChapter),
    };
  }
}
