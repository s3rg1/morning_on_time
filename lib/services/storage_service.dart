import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/day_record.dart';
import '../models/reward.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';
  static const String _recordsKey = 'day_records';
  static const String _rewardsKey = 'rewards';
  static const String _currentStreakKey = 'current_streak';
  static const String _isSetupCompleteKey = 'is_setup_complete';

  Future<AppSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    if (settingsJson == null) return null;
    
    try {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return AppSettings.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<List<DayRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_recordsKey);
    if (recordsJson == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(recordsJson);
      return jsonList.map((json) => DayRecord.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRecords(List<DayRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String recordsJson = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_recordsKey, recordsJson);
  }

  Future<void> addRecord(DayRecord record) async {
    final records = await loadRecords();
    records.add(record);
    await saveRecords(records);
  }

  Future<List<Reward>> loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rewardsJson = prefs.getString(_rewardsKey);
    if (rewardsJson == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(rewardsJson);
      return jsonList.map((json) => Reward.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRewards(List<Reward> rewards) async {
    final prefs = await SharedPreferences.getInstance();
    final String rewardsJson = jsonEncode(rewards.map((r) => r.toJson()).toList());
    await prefs.setString(_rewardsKey, rewardsJson);
  }

  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  Future<void> setCurrentStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStreakKey, streak);
  }

  Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSetupCompleteKey) ?? false;
  }

  Future<void> setSetupComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSetupCompleteKey, complete);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
