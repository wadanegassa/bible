import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';
import '../data/models/bible_version_models.dart';
import '../data/repositories/bible_repository.dart';
import '../core/services/storage_service.dart';

class BibleProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  final StorageService _storageService = StorageService();
  
  List<Book> _books = [];
  List<Verse> _verses = [];
  List<Verse> _bookmarks = [];
  List<Verse> _searchResults = [];
  
  bool _isLoading = false;
  bool _isInitializing = false;
  String? _loadingMessage;
  String? _errorMessage;
  String _currentTranslation = 'AMHARIC_1962';
  
  final List<BibleVersion> _availableVersions = [
    BibleVersion(id: 'MACQUL', name: 'MACQUL', fullname: 'Macaafa Qulqulluu Afaan Oromoo', language: 'Oromo', isDownloaded: false),
    BibleVersion(id: 'AMHARIC_1962', name: 'አማ1962', fullname: 'መጽሐፍ ቅዱስ Haile Selassie (1962)', language: 'Amharic', isDownloaded: true),
    BibleVersion(id: 'NASV', name: 'NASV', fullname: 'አዲሱ መደበኛ ትርጉም', language: 'Amharic', isDownloaded: false),
    BibleVersion(id: 'KJV', name: 'KJV', fullname: 'King James Version', language: 'English', isDownloaded: true),
  ];

  Set<String> _readChapters = {}; // Track chapters read in this session (simple version)
  
  Book? _currentBook; // Keep for next/prev chapter logic
  int? _currentChapter; // Keep for next/prev chapter logic

  Map<String, dynamic> get readingStats => {
    'totalBookmarks': _bookmarks.length,
    'totalHighlights': _verses.where((v) => v.highlightColor != null).length, // Current view only for now
    'chaptersRead': _readChapters.length,
    'currentBookProgress': bookProgress,
  };

  List<Book> get books => _books;
  List<Verse> get verses => _verses;
  List<Verse> get bookmarks => _bookmarks;
  List<Verse> get searchResults => _searchResults;
  List<BibleVersion> get availableVersions => _availableVersions;
  
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get loadingMessage => _loadingMessage;
  String? get errorMessage => _errorMessage;
  String get currentTranslation => _currentTranslation;
  Book? get currentBook => _currentBook;
  int? get currentChapter => _currentChapter;

  double get bookProgress {
    if (_currentBook == null || _currentChapter == null || _currentBook!.chapterCount == 0) return 0.0;
    return _currentChapter! / _currentBook!.chapterCount;
  }

  Future<void> init({bool isStartup = false}) async {
    _isInitializing = true;
    _loadingMessage = isStartup ? 'Waking up divine wisdom...' : 'Switching translation...';
    _errorMessage = null;
    notifyListeners();

    try {
      String? savedBookId;
      int? savedChapter;

      if (isStartup) {
        // Load session only on startup
        final session = await _storageService.loadSession();
        if (session['translation'] != null) {
          _currentTranslation = session['translation'];
        }
        savedBookId = session['bookId'];
        savedChapter = session['chapter'];
      }

      _loadingMessage = 'Preparing ${getVersionName(_currentTranslation)}...';
      notifyListeners();
      
      await _repository.ensureInitialized(translation: _currentTranslation);
      _books = _repository.getBooks(_currentTranslation);
      await loadBookmarks();
      
      // Load last picked book and chapter or default
      if (savedBookId != null && savedChapter != null) {
        await loadChapter(savedBookId, savedChapter, save: false);
      } else if (_currentBook == null && _books.isNotEmpty) {
        // If switching translation, _currentBook is null, so load first book of new translation
        await loadChapter(_books.first.id, 1, save: !isStartup);
      } else if (_currentBook != null && _currentChapter != null) {
        // This case might happen if init is called but we already have a selection
        await loadChapter(_currentBook!.id, _currentChapter!, save: !isStartup);
      }
      
      _isInitializing = false;
      _loadingMessage = null;
    } catch (e) {
      _isInitializing = false;
      _loadingMessage = null;
      _errorMessage = 'Failed to load Bible: $e';
    }
    notifyListeners();
  }

  String getVersionName(String id) {
    return _availableVersions.firstWhere((v) => v.id == id, orElse: () => _availableVersions.first).name;
  }

  Future<void> setTranslation(String translation) async {
    if (_currentTranslation == translation) return;
    _currentTranslation = translation;
    
    // Clear current selection when switching translation to avoid ID mismatches
    _currentBook = null;
    _currentChapter = null;
    
    await init();
  }

  Future<void> loadChapter(String bookId, int chapter, {bool save = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _verses = await _repository.getVerses(bookId, chapter, translation: _currentTranslation);
      // Update _currentBook and _currentChapter based on the loaded chapter
      _currentBook = _books.firstWhere((b) => b.id == bookId, orElse: () => Book(id: '', name: '', chapterCount: 0, testament: Testament.oldTestament));
      _currentChapter = chapter;
      _readChapters.add('$bookId.$chapter'); // Mark as read
      
      if (save) {
        await _storageService.saveSession(_currentTranslation, bookId, chapter);
      }
      
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load chapter: $e';
    }
    notifyListeners();
  }

  Future<void> downloadVersion(BibleVersion version) async {
    // Mock download process
    _isLoading = true;
    _loadingMessage = 'Downloading ${version.fullname}...';
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    
    final index = _availableVersions.indexWhere((v) => v.id == version.id);
    if (index != -1) {
      _availableVersions[index] = _availableVersions[index].copyWith(isDownloaded: true);
      
      // Ensure the newly downloaded version is initialized in the DB
      await _repository.ensureInitialized(translation: version.id);
    }
    
    _isLoading = false;
    _loadingMessage = null;
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

  Future<void> updateHighlight(Verse verse, String? color) async {
    try {
      await _repository.updateHighlight(verse, color);
      
      final index = _verses.indexWhere((v) => v.dbId == verse.dbId);
      if (index != -1) {
        _verses[index] = verse.copyWith(highlightColor: color, clearHighlight: color == null);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update highlight: $e';
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

