import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import '../data/repositories/bible_repository.dart';

class BibleProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();

  List<Book> _books = [];
  List<Verse> _verses = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  Book? _currentBook;
  int? _currentChapter;

  List<Book> get books => _books;
  List<Verse> get verses => _verses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Book? get currentBook => _currentBook;
  int? get currentChapter => _currentChapter;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _books = await _repository.getBooks();
      if (_books.isEmpty) {
        _errorMessage = "No books loaded.";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVerses(Book book, int chapter) async {
    _isLoading = true;
    _verses = [];
    _errorMessage = null;
    _currentBook = book;
    _currentChapter = chapter;
    notifyListeners();
    
    try {
      _verses = await _repository.getVerses(book.id, chapter);
      if (_verses.isEmpty) {
        _errorMessage = "Could not load verses. Check your connection.";
      }
    } catch (e) {
      _errorMessage = "Error loading verses: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! < _currentBook!.chapterCount) {
      loadVerses(_currentBook!, _currentChapter! + 1);
    } else {
      // Move to next book
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex != -1 && currentIndex < _books.length - 1) {
        final nextBook = _books[currentIndex + 1];
        loadVerses(nextBook, 1);
      }
    }
  }

  void prevChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! > 1) {
      loadVerses(_currentBook!, _currentChapter! - 1);
    } else {
      // Move to previous book
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex > 0) {
        final prevBook = _books[currentIndex - 1];
        loadVerses(prevBook, prevBook.chapterCount);
      }
    }
  }

  Future<List<Verse>> search(String query) async {
    if (query.isEmpty) return [];
    
    final trimmedQuery = query.trim();
    
    // Try to parse as reference: "Book Chapter" or "Book Chapter:Verse"
    // Supports English and potentially some Amharic characters (simplified regex)
    final refMatch = RegExp(r'^(.+?)\s+(\d+)(?::(\d+))?$').firstMatch(trimmedQuery);
    
    if (refMatch != null) {
      final bookName = refMatch.group(1)!.trim().toLowerCase();
      final chapter = int.parse(refMatch.group(2)!);
      final verseNum = refMatch.group(3) != null ? int.parse(refMatch.group(3)!) : null;
      
      // Try to find the book by name or ID
      final book = _books.firstWhere(
        (b) => b.name.toLowerCase() == bookName || b.id.toLowerCase() == bookName,
        orElse: () => Book(id: '', name: '', chapterCount: 0, testament: Testament.oldTestament),
      );
      
      if (book.id.isNotEmpty) {
        try {
          final chapterVerses = await _repository.getVerses(book.id, chapter);
          if (verseNum != null) {
            return chapterVerses.where((v) => v.verse == verseNum).toList();
          }
          return chapterVerses;
        } catch (_) {
          // Fallback to keyword search if API fetch fails
        }
      }
    }
    
    return await _repository.search(query);
  }

  Future<void> toggleBookmark(Verse verse) async {
    // 1. Update Repository (DB)
    await _repository.toggleBookmark(verse);
    
    // 2. Update Local State (List<Verse>)
    final index = _verses.indexWhere((v) => v.id == verse.id);
    if (index != -1) {
      _verses[index] = verse.copyWith(isBookmarked: !verse.isBookmarked);
      notifyListeners();
    }
  }
}
