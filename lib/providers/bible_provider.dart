import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import '../data/repositories/bible_repository.dart';

class BibleProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();

  List<Book> _books = [];
  List<Verse> _verses = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Book> get books => _books;
  List<Verse> get verses => _verses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadVerses(String bookId, int chapter) async {
    _isLoading = true;
    _verses = [];
    _errorMessage = null;
    notifyListeners();
    
    try {
      _verses = await _repository.getVerses(bookId, chapter);
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

  Future<List<Verse>> search(String query) async {
    if (query.isEmpty) return [];
    return await _repository.search(query);
  }
}
