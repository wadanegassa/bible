import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import '../data/repositories/bible_repository.dart';

class BibleProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  
  List<Book> _books = [];
  List<Verse> _verses = [];
  List<Verse> _bookmarks = [];
  List<Verse> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentTranslation = 'KJV'; // Default
  
  Book? _currentBook; // Keep for next/prev chapter logic
  int? _currentChapter; // Keep for next/prev chapter logic

  List<Book> get books => _books;
  List<Verse> get verses => _verses;
  List<Verse> get bookmarks => _bookmarks;
  List<Verse> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentTranslation => _currentTranslation;
  Book? get currentBook => _currentBook;
  int? get currentChapter => _currentChapter;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.ensureInitialized(translation: _currentTranslation);
      _books = _repository.getBooks(_currentTranslation);
      await loadBookmarks();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load Bible: $e';
    }
    notifyListeners();
  }

  Future<void> setTranslation(String translation) async {
    if (_currentTranslation == translation) return;
    _currentTranslation = translation;
    await init();
  }

  Future<void> loadChapter(String bookId, int chapter) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _verses = await _repository.getVerses(bookId, chapter, translation: _currentTranslation);
      // Update _currentBook and _currentChapter based on the loaded chapter
      _currentBook = _books.firstWhere((b) => b.id == bookId, orElse: () => Book(id: '', name: '', chapterCount: 0, testament: Testament.oldTestament));
      _currentChapter = chapter;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load chapter: $e';
    }
    notifyListeners();
  }

  void nextChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! < _currentBook!.chapterCount) {
      loadChapter(_currentBook!.id, _currentChapter! + 1);
    } else {
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex != -1 && currentIndex < _books.length - 1) {
        final nextBook = _books[currentIndex + 1];
        loadChapter(nextBook.id, 1);
      }
    }
  }

  void prevChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! > 1) {
      loadChapter(_currentBook!.id, _currentChapter! - 1);
    } else {
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex > 0) {
        final prevBook = _books[currentIndex - 1];
        loadChapter(prevBook.id, prevBook.chapterCount);
      }
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _repository.search(query, translation: _currentTranslation);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Search failed: $e';
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(Verse verse) async {
    try {
      await _repository.toggleBookmark(verse);
      await loadBookmarks();
      
      final index = _verses.indexWhere((v) => v.dbId == verse.dbId);
      if (index != -1) {
        _verses[index] = verse.copyWith(isBookmarked: !verse.isBookmarked);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update bookmark: $e';
      notifyListeners();
    }
  }

  Future<void> loadBookmarks() async {
    try {
      _bookmarks = await _repository.getBookmarks(translation: _currentTranslation);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }
}
