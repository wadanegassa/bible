import 'package:flutter/material.dart';
import '../core/services/daily_verse_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/verse_text.dart';
import '../data/models/bible_models.dart';
import '../data/models/bible_version_models.dart';
import '../data/plans/reading_plans.dart';
import '../data/repositories/bible_repository.dart';

class BibleProvider with ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  final StorageService _storageService = StorageService();
  final DailyVerseService _dailyVerseService = DailyVerseService();

  List<Book> _books = [];
  List<Verse> _verses = [];
  List<Verse> _bookmarks = [];
  List<Verse> _highlights = [];
  List<Verse> _searchResults = [];
  List<BibleVersion> _availableVersions = [];
  List<String> _defaultIds = const ['gaz', 'am', 'engwebp'];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _history = [];
  List<String> _compareIds = [];

  bool _isLoading = false;
  bool _isInitializing = false;
  String? _loadingMessage;
  String? _errorMessage;
  String _currentTranslation = 'gaz';
  String? _installingId;

  final Set<String> _readChapters = {};
  Book? _currentBook;
  int? _currentChapter;

  int _streak = 0;
  String? _lastReadDay;
  Verse? _dailyVerse;
  bool _familyMode = false;
  bool _reminderEnabled = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;

  String? _activePlanId;
  int _activePlanDay = 1;
  List<int> _planCompletedDays = [];

  Map<String, dynamic> get readingStats => {
        'totalBookmarks': _bookmarks.length,
        'totalHighlights': _highlights.length,
        'totalNotes': _notes.length,
        'chaptersRead': _readChapters.length,
        'currentBookProgress': bookProgress,
        'streak': _streak,
      };

  List<Book> get books => _books;
  List<Verse> get verses => _verses;
  List<Verse> get bookmarks => _bookmarks;
  List<Verse> get highlights => _highlights;
  List<Verse> get searchResults => _searchResults;
  List<BibleVersion> get availableVersions => _availableVersions;
  List<BibleVersion> get downloadedVersions =>
      _availableVersions.where((v) => v.isDownloaded).toList();
  List<BibleVersion> get optionalVersions =>
      _availableVersions.where((v) => !v.bundled).toList();

  /// The three always-offline defaults for the home version card.
  List<BibleVersion> get defaultVersions {
    final byId = {for (final v in _availableVersions) v.id: v};
    final ordered = <BibleVersion>[
      for (final id in _defaultIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
    if (ordered.isNotEmpty) return ordered;
    return _availableVersions.where((v) => v.bundled).toList();
  }

  /// Version picker: defaults first, then any extra installed packs.
  List<BibleVersion> get versionCardVersions {
    final defaults = defaultVersions;
    final defaultIds = defaults.map((v) => v.id).toSet();
    final extras = downloadedVersions
        .where((v) => !defaultIds.contains(v.id) && !v.bundled)
        .toList();
    return [...defaults, ...extras];
  }
  List<Map<String, dynamic>> get notes => _notes;
  List<Map<String, dynamic>> get history => _history;
  List<String> get compareIds => List.unmodifiable(_compareIds);

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get loadingMessage => _loadingMessage;
  String? get errorMessage => _errorMessage;
  String get currentTranslation => _currentTranslation;
  String? get installingId => _installingId;
  Book? get currentBook => _currentBook;
  int? get currentChapter => _currentChapter;

  int get streak => _streak;
  String? get lastReadDay => _lastReadDay;
  Verse? get dailyVerse => _dailyVerse;
  bool get familyMode => _familyMode;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  String? get activePlanId => _activePlanId;
  int get activePlanDay => _activePlanDay;
  List<int> get planCompletedDays => List.unmodifiable(_planCompletedDays);

  ReadingPlan? get activePlan => ReadingPlans.byId(_activePlanId);

  bool get readToday {
    final today = _dayKey(DateTime.now());
    return _lastReadDay == today;
  }

  String? get continueLabel {
    if (_currentBook == null || _currentChapter == null) return null;
    return '${_currentBook!.name} $_currentChapter';
  }

  BibleVersion? get currentVersion {
    if (_availableVersions.isEmpty) return null;
    return _availableVersions.firstWhere(
      (v) => v.id == _currentTranslation,
      orElse: () => _availableVersions.first,
    );
  }

  bool get isRtl => currentVersion?.textDirection == 'rtl';
  bool get hasDeuterocanon =>
      _books.any((b) => b.testament == Testament.deuterocanonical);

  double get bookProgress {
    if (_currentBook == null ||
        _currentChapter == null ||
        _currentBook!.chapterCount == 0) {
      return 0.0;
    }
    return _currentChapter! / _currentBook!.chapterCount;
  }

  double get planProgress {
    final plan = activePlan;
    if (plan == null || plan.length == 0) return 0;
    return _planCompletedDays.length / plan.length;
  }

  Future<void> init({bool isStartup = false}) async {
    _isInitializing = true;
    _loadingMessage = isStartup ? 'Opening Bible…' : 'Switching translation…';
    _errorMessage = null;
    notifyListeners();

    try {
      String? savedBookId;
      int? savedChapter;
      var preferredId = _currentTranslation;

      if (isStartup) {
        await _loadEngagementPrefs();
        final session = await _storageService.loadSession();
        preferredId = session['translation'] as String? ?? _defaultIds.first;
        savedBookId = session['bookId'] as String?;
        savedChapter = session['chapter'] as int?;
      }

      // Auto-install only the 3 bundled defaults (MacQul, አመት, KJV).
      final catalog = await _repository.ensureReady(preferredId: preferredId);
      _defaultIds = catalog.defaultTranslationIds;
      _availableVersions = List<BibleVersion>.from(catalog.translations);

      final preferredOk = _availableVersions.any(
        (v) => v.id == preferredId && (v.isDownloaded || v.bundled),
      );
      if (preferredOk) {
        _currentTranslation = preferredId;
      } else if (_defaultIds.isNotEmpty) {
        _currentTranslation = _defaultIds.first;
      } else if (downloadedVersions.isNotEmpty) {
        _currentTranslation = downloadedVersions.first.id;
      }

      _books = await _repository.getBooks(_currentTranslation);
      await Future.wait([
        loadBookmarks(),
        loadHighlights(),
        loadNotes(),
        loadHistory(),
        refreshDailyVerse(),
      ]);

      if (savedBookId != null &&
          savedChapter != null &&
          _books.any((b) => b.id == savedBookId)) {
        await loadChapter(savedBookId, savedChapter, save: false);
      } else if (_books.isNotEmpty) {
        await loadChapter(_books.first.id, 1, save: !isStartup);
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

  Future<void> _loadEngagementPrefs() async {
    final streakData = await _storageService.loadStreak();
    _streak = streakData.streak;
    _lastReadDay = streakData.lastReadDay;

    final plan = await _storageService.loadActivePlan();
    _activePlanId = plan.planId;
    _activePlanDay = plan.day;
    _planCompletedDays = List<int>.from(plan.completedDays);

    _familyMode = await _storageService.loadFamilyMode();
    final reminder = await _storageService.loadReminder();
    _reminderEnabled = reminder.enabled;
    _reminderHour = reminder.hour;
    _reminderMinute = reminder.minute;
    _compareIds = await _storageService.loadCompareIds();
  }

  String getVersionName(String id) {
    for (final v in _availableVersions) {
      if (v.id == id) return v.shortName;
    }
    return id.toUpperCase();
  }

  Future<void> setTranslation(String translation) async {
    if (_currentTranslation == translation) return;
    final version = _availableVersions.firstWhere((v) => v.id == translation);
    if (!version.isDownloaded) {
      await installVersion(version);
      return;
    }
    _currentTranslation = translation;
    _currentBook = null;
    _currentChapter = null;
    await init();
  }

  Future<void> loadChapter(String bookId, int chapter, {bool save = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _verses = await _repository.getVerses(
        bookId,
        chapter,
        translation: _currentTranslation,
      );
      _currentBook = _books.firstWhere(
        (b) => b.id == bookId,
        orElse: () => Book(
          id: '',
          name: '',
          chapterCount: 0,
          testament: Testament.oldTestament,
        ),
      );
      _currentChapter = chapter;
      _readChapters.add('$bookId.$chapter');

      if (save) {
        await _storageService.saveSession(_currentTranslation, bookId, chapter);
        await _repository.addHistory(
          translation: _currentTranslation,
          bookId: bookId,
          bookName: _currentBook?.name ?? bookId,
          chapter: chapter,
        );
        _streak = await _storageService.recordReadingDay();
        final streakData = await _storageService.loadStreak();
        _lastReadDay = streakData.lastReadDay;
        await loadHistory();
      }

      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load chapter: $e';
    }
    notifyListeners();
  }

  Future<void> continueReading() async {
    if (_currentBook != null && _currentChapter != null) {
      await loadChapter(_currentBook!.id, _currentChapter!);
      return;
    }
    final session = await _storageService.loadSession();
    final bookId = session['bookId'] as String?;
    final chapter = session['chapter'] as int?;
    if (bookId != null && chapter != null) {
      await loadChapter(bookId, chapter);
    } else if (_books.isNotEmpty) {
      await loadChapter(_books.first.id, 1);
    }
  }

  Future<void> openDailyVerse() async {
    final verse = _dailyVerse;
    if (verse == null) return;
    await loadChapter(verse.bookId, verse.chapter);
  }

  Future<void> installVersion(BibleVersion version) async {
    if (_installingId != null) return;
    // Bundled packs are marked downloaded in the UI but may still need a first SQLite install.
    if (version.isDownloaded && !version.bundled) return;

    _installingId = version.id;
    _isLoading = true;
    _loadingMessage = 'Installing ${version.fullname} offline...';
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.installVersion(version);
      final catalog = await _repository.loadCatalog(forceReload: true);
      _availableVersions = List<BibleVersion>.from(catalog.translations);
      _currentTranslation = version.id;
      _currentBook = null;
      _currentChapter = null;
      _books = await _repository.getBooks(_currentTranslation);
      await Future.wait([
        loadBookmarks(),
        loadHighlights(),
        loadNotes(),
        refreshDailyVerse(),
      ]);
      if (_books.isNotEmpty) {
        await loadChapter(_books.first.id, 1);
      }
    } catch (e) {
      _errorMessage = 'Install failed: $e';
    } finally {
      _installingId = null;
      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
    }
  }

  Future<void> uninstallVersion(BibleVersion version) async {
    if (version.bundled) {
      _errorMessage = 'Default offline Bibles cannot be removed.';
      notifyListeners();
      return;
    }
    if (!version.isDownloaded) return;

    _isLoading = true;
    _loadingMessage = 'Removing ${version.fullname}...';
    notifyListeners();

    try {
      final wasCurrent = _currentTranslation == version.id;
      await _repository.uninstallVersion(version);
      final catalog = await _repository.loadCatalog(forceReload: true);
      _availableVersions = List<BibleVersion>.from(catalog.translations);

      _compareIds.remove(version.id);
      await _storageService.saveCompareIds(_compareIds);

      if (wasCurrent) {
        _currentTranslation = downloadedVersions.first.id;
        _currentBook = null;
        _currentChapter = null;
        _books = await _repository.getBooks(_currentTranslation);
        await Future.wait([
          loadBookmarks(),
          loadHighlights(),
          loadNotes(),
          refreshDailyVerse(),
        ]);
        if (_books.isNotEmpty) {
          await loadChapter(_books.first.id, 1);
        }
      }
    } catch (e) {
      _errorMessage = 'Remove failed: $e';
    } finally {
      _isLoading = false;
      _loadingMessage = null;
      notifyListeners();
    }
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
      _searchResults = await _repository.search(
        query,
        translation: _currentTranslation,
      );
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
        _verses[index] = verse.copyWith(
          highlightColor: color,
          clearHighlight: color == null,
        );
      }
      await loadHighlights();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update highlight: $e';
      notifyListeners();
    }
  }

  Future<void> loadBookmarks() async {
    try {
      _bookmarks = await _repository.getBookmarks(
        translation: _currentTranslation,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<void> loadHighlights() async {
    try {
      _highlights = await _repository.getHighlights(
        translation: _currentTranslation,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading highlights: $e');
    }
  }

  Future<void> loadNotes({String? query}) async {
    try {
      _notes = await _repository.getNotes(
        translation: _currentTranslation,
        query: query,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      _history = await _repository.getHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> refreshDailyVerse() async {
    try {
      _dailyVerse = await _dailyVerseService.loadForTranslation(_currentTranslation);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily verse: $e');
    }
  }

  Future<String?> getNoteForVerse(Verse verse) {
    return _repository.getNote(
      translation: _currentTranslation,
      bookId: verse.bookId,
      chapter: verse.chapter,
      verse: verse.verse,
    );
  }

  Future<void> saveNote(Verse verse, String note) async {
    await _repository.upsertNote(
      translation: _currentTranslation,
      bookId: verse.bookId,
      bookName: verse.bookName,
      chapter: verse.chapter,
      verse: verse.verse,
      note: note,
    );
    await loadNotes();
  }

  Future<void> setFamilyMode(bool enabled) async {
    _familyMode = enabled;
    await _storageService.saveFamilyMode(enabled);
    notifyListeners();
  }

  Future<void> setReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    _reminderEnabled = enabled;
    if (hour != null) _reminderHour = hour;
    if (minute != null) _reminderMinute = minute;
    await _storageService.saveReminder(
      enabled: _reminderEnabled,
      hour: _reminderHour,
      minute: _reminderMinute,
    );
    notifyListeners();
  }

  Future<void> setCompareIds(List<String> ids) async {
    _compareIds = ids.where((id) => id != _currentTranslation).take(3).toList();
    await _storageService.saveCompareIds(_compareIds);
    notifyListeners();
  }

  Future<void> toggleCompareId(String id) async {
    if (id == _currentTranslation) return;
    final next = List<String>.from(_compareIds);
    if (next.contains(id)) {
      next.remove(id);
    } else if (next.length < 3) {
      next.add(id);
    }
    await setCompareIds(next);
  }

  Future<Map<String, Verse?>> compareVerse(Verse verse) async {
    final ids = <String>{_currentTranslation, ..._compareIds};
    final result = <String, Verse?>{};
    for (final id in ids) {
      if (id == _currentTranslation) {
        result[id] = verse;
        continue;
      }
      result[id] = await _repository.getVerseByRef(
        translation: id,
        bookId: verse.bookId,
        chapter: verse.chapter,
        verse: verse.verse,
      );
    }
    return result;
  }

  Future<void> startPlan(String planId) async {
    final plan = ReadingPlans.byId(planId);
    if (plan == null) return;
    _activePlanId = planId;
    _activePlanDay = 1;
    _planCompletedDays = [];
    await _storageService.saveActivePlan(
      planId: planId,
      day: 1,
      completedDays: _planCompletedDays,
    );
    notifyListeners();
  }

  Future<void> clearPlan() async {
    _activePlanId = null;
    _activePlanDay = 1;
    _planCompletedDays = [];
    await _storageService.saveActivePlan(
      planId: null,
      day: 1,
      completedDays: const [],
    );
    notifyListeners();
  }

  Future<void> openPlanDay(PlanDay day) async {
    await loadChapter(day.bookId, day.chapter);
  }

  Future<void> completePlanDay(int day) async {
    final plan = activePlan;
    if (plan == null) return;
    if (!_planCompletedDays.contains(day)) {
      _planCompletedDays = [..._planCompletedDays, day]..sort();
    }
    final next = (day + 1).clamp(1, plan.length);
    _activePlanDay = next;
    await _storageService.saveActivePlan(
      planId: _activePlanId,
      day: _activePlanDay,
      completedDays: _planCompletedDays,
    );
    notifyListeners();
  }

  String formatVerseCopy(Verse verse, {String? translationId}) {
    final id = translationId ?? _currentTranslation;
    final short = getVersionName(id);
    return '${cleanVerseText(verse.text)}\n\n— ${verse.reference} · $short';
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
