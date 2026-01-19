import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import '../data/repositories/bible_repository.dart';

class BookmarkProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  List<Verse> _bookmarks = [];

  List<Verse> get bookmarks => _bookmarks;

  Future<void> loadBookmarks() async {
    _bookmarks = await _repository.getBookmarks();
    notifyListeners();
  }

  Future<void> toggleBookmark(Verse verse) async {
    await _repository.toggleBookmark(verse);
    await loadBookmarks();
  }
}
