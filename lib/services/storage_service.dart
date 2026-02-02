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
  static const String _journeyActiveKey = 'journey_active';
  static const String _journeyStartTimeKey = 'journey_start_time';
  static const String _testArrivalDeadlineKey = 'test_arrival_deadline';
  static const String _arrivalConfirmedKey = 'arrival_confirmed';

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

  Future<bool> isJourneyActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_journeyActiveKey) ?? false;
  }

  Future<void> setJourneyActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_journeyActiveKey, active);
    if (active) {
      await prefs.setString(_journeyStartTimeKey, DateTime.now().toIso8601String());
    } else {
      await prefs.remove(_journeyStartTimeKey);
    }
  }

  Future<DateTime?> getJourneyStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timeStr = prefs.getString(_journeyStartTimeKey);
    if (timeStr == null) return null;
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> setTestArrivalDeadline(DateTime? deadline) async {
    final prefs = await SharedPreferences.getInstance();
    if (deadline != null) {
      await prefs.setString(_testArrivalDeadlineKey, deadline.toIso8601String());
    } else {
      await prefs.remove(_testArrivalDeadlineKey);
    }
  }

  Future<DateTime?> getTestArrivalDeadline() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timeStr = prefs.getString(_testArrivalDeadlineKey);
    if (timeStr == null) return null;
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> setArrivalConfirmed(bool confirmed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_arrivalConfirmedKey, confirmed);
  }

  Future<bool> getArrivalConfirmed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_arrivalConfirmedKey) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
