import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyTranslation = 'last_translation';
  static const String _keyBookId = 'last_book_id';
  static const String _keyChapter = 'last_chapter';
  static const String _keyStreakCount = 'streak_count';
  static const String _keyLastReadDay = 'last_read_day'; // yyyy-MM-dd
  static const String _keyActivePlanId = 'active_plan_id';
  static const String _keyPlanDay = 'active_plan_day';
  static const String _keyPlanCompleted = 'active_plan_completed'; // JSON list of day ints
  static const String _keyFamilyMode = 'family_mode';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyCompareIds = 'compare_translation_ids';

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

  Future<({int streak, String? lastReadDay})> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      streak: prefs.getInt(_keyStreakCount) ?? 0,
      lastReadDay: prefs.getString(_keyLastReadDay),
    );
  }

  Future<int> recordReadingDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dayKey(DateTime.now());
    final last = prefs.getString(_keyLastReadDay);
    var streak = prefs.getInt(_keyStreakCount) ?? 0;

    if (last == today) {
      return streak;
    }

    if (last != null) {
      final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
      streak = last == yesterday ? streak + 1 : 1;
    } else {
      streak = 1;
    }

    await prefs.setString(_keyLastReadDay, today);
    await prefs.setInt(_keyStreakCount, streak);
    return streak;
  }

  Future<void> saveActivePlan({
    required String? planId,
    required int day,
    required List<int> completedDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (planId == null) {
      await prefs.remove(_keyActivePlanId);
      await prefs.remove(_keyPlanDay);
      await prefs.remove(_keyPlanCompleted);
      return;
    }
    await prefs.setString(_keyActivePlanId, planId);
    await prefs.setInt(_keyPlanDay, day);
    await prefs.setString(_keyPlanCompleted, jsonEncode(completedDays));
  }

  Future<({String? planId, int day, List<int> completedDays})> loadActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPlanCompleted);
    List<int> completed = [];
    if (raw != null && raw.isNotEmpty) {
      completed = (jsonDecode(raw) as List).map((e) => e as int).toList();
    }
    return (
      planId: prefs.getString(_keyActivePlanId),
      day: prefs.getInt(_keyPlanDay) ?? 1,
      completedDays: completed,
    );
  }

  Future<bool> loadFamilyMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFamilyMode) ?? false;
  }

  Future<void> saveFamilyMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFamilyMode, enabled);
  }

  Future<({bool enabled, int hour, int minute})> loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      enabled: prefs.getBool(_keyReminderEnabled) ?? false,
      hour: prefs.getInt(_keyReminderHour) ?? 20,
      minute: prefs.getInt(_keyReminderMinute) ?? 0,
    );
  }

  Future<void> saveReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, enabled);
    await prefs.setInt(_keyReminderHour, hour);
    await prefs.setInt(_keyReminderMinute, minute);
  }

  Future<List<String>> loadCompareIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompareIds) ?? <String>[];
  }

  Future<void> saveCompareIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompareIds, ids);
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
