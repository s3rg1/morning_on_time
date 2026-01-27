import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/day_record.dart';
import '../models/reward.dart';
import '../models/check_in_status.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/voice_service.dart';
import '../services/streak_service.dart';
import '../services/alarm_service.dart';
import '../services/localization_helper.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final VoiceService _voice = VoiceService();
  final StreakService _streakService = StreakService();

  AppSettings? _settings;
  List<DayRecord> _records = [];
  List<Reward> _rewards = [];
  int _currentStreak = 0;
  CheckInStatus _todayCheckIn = CheckInStatus.notStarted;
  bool _isLoading = true;
  bool _isSetupComplete = false;

  AppSettings? get settings => _settings;
  List<DayRecord> get records => List.unmodifiable(_records);
  List<Reward> get rewards => List.unmodifiable(_rewards);
  int get currentStreak => _currentStreak;
  CheckInStatus get todayCheckIn => _todayCheckIn;
  bool get isLoading => _isLoading;
  bool get isSetupComplete => _isSetupComplete;
  NotificationService get notificationService => _notifications;

  Future<void> _saveDeviceLocale() async {
    try {
      // Get device locale from Platform
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      await LocalizationHelper.saveLocale(locale.languageCode);
    } catch (e) {
      print('Error saving locale, defaulting to English: $e');
      await LocalizationHelper.saveLocale('en');
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Save device locale for background isolates to use
    // This is needed because background isolates don't have access to BuildContext
    await _saveDeviceLocale();

    await _notifications.initialize();
    await _notifications.requestPermissions();
    
    // Cancel all previous alarms/notifications to prevent stale alarms from firing
    await AlarmService.cancelAll();
    await _notifications.cancelAll();
    
    // Set up notification callback for check-in responses
    NotificationService.onCheckInResponse = (status) {
      updateCheckInStatus(status);
    };
    
    // Set up notification callback for arrival confirmation
    NotificationService.onArrivalConfirmation = (arrivedOnTime) {
      confirmArrival(arrivedOnTime);
    };

    _settings = await _storage.loadSettings();
    _records = await _storage.loadRecords();
    _rewards = await _storage.loadRewards();
    _currentStreak = _streakService.calculateCurrentStreak(_records);
    _isSetupComplete = await _storage.isSetupComplete();

    if (_settings != null) {
      // Reschedule all notifications and alarms with current settings
      await _notifications.scheduleAllNotifications(_settings!);
      
      // Reschedule AlarmService alarms
      final now = DateTime.now();
      
      var wakeUpDate = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.wakeUpTime.hour,
        _settings!.wakeUpTime.minute,
      );
      if (wakeUpDate.isBefore(now)) {
        wakeUpDate = wakeUpDate.add(const Duration(days: 1));
      }
      
      var leaveHomeDate = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.leaveHomeTime.hour,
        _settings!.leaveHomeTime.minute,
      );
      if (leaveHomeDate.isBefore(now)) {
        leaveHomeDate = leaveHomeDate.add(const Duration(days: 1));
      }
      
      var arrivalDate = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.arrivalDeadline.hour,
        _settings!.arrivalDeadline.minute,
      );
      if (arrivalDate.isBefore(now)) {
        arrivalDate = arrivalDate.add(const Duration(days: 1));
      }
      
      await AlarmService.scheduleWakeUpAlarm(wakeUpDate);
      await AlarmService.scheduleCheckInAlarms(wakeUpDate, leaveHomeDate);
      await AlarmService.scheduleLeaveHomeSoonAlarm(leaveHomeDate);
      await AlarmService.scheduleLeaveHomeAlarm(leaveHomeDate);
      await AlarmService.scheduleArrivalCheckAlarm(arrivalDate);
    }

    // List all scheduled notifications on app launch
    await _notifications.listAllScheduledNotifications(_settings);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _storage.saveSettings(settings);
    await _storage.setSetupComplete(true);
    _isSetupComplete = true;
    
    // Cancel all previous alarms before scheduling new ones
    await AlarmService.cancelAll();
    
    final now = DateTime.now();
    
    // 1. Schedule wake-up alarm
    var wakeUpDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.wakeUpTime.hour,
      settings.wakeUpTime.minute,
    );
    if (wakeUpDate.isBefore(now)) {
      wakeUpDate = wakeUpDate.add(const Duration(days: 1));
    }
    await AlarmService.scheduleWakeUpAlarm(wakeUpDate);
    
    // 2. Schedule multiple check-in alarms (every 8 minutes until 6 minutes before leave)
    var leaveHomeDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.leaveHomeTime.hour,
      settings.leaveHomeTime.minute,
    );
    if (leaveHomeDate.isBefore(now)) {
      leaveHomeDate = leaveHomeDate.add(const Duration(days: 1));
    }
    await AlarmService.scheduleCheckInAlarms(wakeUpDate, leaveHomeDate);
    
    // 3. Schedule leave-home-soon alarm (5 minutes before leave)
    await AlarmService.scheduleLeaveHomeSoonAlarm(leaveHomeDate);
    
    // 4. Schedule leave-home alarm (at leave time)
    await AlarmService.scheduleLeaveHomeAlarm(leaveHomeDate);
    
    // 5. Schedule arrival check alarm (2 minutes before arrival)
    var arrivalDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.arrivalDeadline.hour,
      settings.arrivalDeadline.minute,
    );
    if (arrivalDate.isBefore(now)) {
      arrivalDate = arrivalDate.add(const Duration(days: 1));
    }
    await AlarmService.scheduleArrivalCheckAlarm(arrivalDate);
    
    print('✅ All alarms scheduled successfully');
    
    notifyListeners();
  }

  Future<void> updateCheckInStatus(CheckInStatus status) async {
    _todayCheckIn = status;
    notifyListeners();
  }

  Future<void> confirmArrival(bool onTime) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if we already have a record for today
    final existingIndex = _records.indexWhere((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate.isAtSameMomentAs(todayDate);
    });

    final newRecord = DayRecord(
      date: todayDate,
      wasOnTime: onTime,
      arrivalTime: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _records[existingIndex] = newRecord;
    } else {
      _records.add(newRecord);
    }

    await _storage.saveRecords(_records);

    // Recalculate streak
    _currentStreak = _streakService.calculateCurrentStreak(_records);
    await _storage.setCurrentStreak(_currentStreak);

    // Play appropriate message
    if (onTime) {
      await _voice.playSuccessMessage(_currentStreak);
      
      // Check for reward eligibility
      final nextReward = _getNextReward();
      if (nextReward != null) {
        final daysRemaining = nextReward.requiredStreakLength - _currentStreak;
        if (daysRemaining >= 0 && daysRemaining <= 2) {
          await _voice.playRewardMessage(nextReward.name, daysRemaining);
        }
      }
    } else {
      await _voice.playFailureMessage();
    }

    // Reset check-in for next day
    _todayCheckIn = CheckInStatus.notStarted;

    notifyListeners();
  }

  Future<void> addReward(Reward reward) async {
    _rewards.add(reward);
    await _storage.saveRewards(_rewards);
    notifyListeners();
  }

  Future<void> updateReward(String id, Reward updatedReward) async {
    final index = _rewards.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _rewards[index] = updatedReward;
      await _storage.saveRewards(_rewards);
      notifyListeners();
    }
  }

  Future<void> deleteReward(String id) async {
    _rewards.removeWhere((r) => r.id == id);
    await _storage.saveRewards(_rewards);
    notifyListeners();
  }

  Future<void> playWakeUpMessage() async {
    await _voice.playWakeUpMessage();
  }

  Future<void> playTimeReminder(int minutes) async {
    await _voice.playTimeToLeaveMessage(minutes, _todayCheckIn);
    await _notifications.showTimeToLeaveNotification(minutes, _todayCheckIn);
  }

  Future<void> showArrivalPrompt() async {
    await _notifications.showArrivalPrompt();
  }

  List<DayRecord> getRecordsForMonth(int year, int month) {
    return _records.where((record) {
      return record.date.year == year && record.date.month == month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Reward? _getNextReward() {
    final activeRewards = _rewards.where((r) => r.isActive).toList()
      ..sort((a, b) => a.requiredStreakLength.compareTo(b.requiredStreakLength));
    
    for (final reward in activeRewards) {
      if (reward.requiredStreakLength > _currentStreak) {
        return reward;
      }
    }
    
    return null;
  }

  DayRecord? getTodayRecord() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    try {
      return _records.firstWhere((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate.isAtSameMomentAs(todayDate);
      });
    } catch (e) {
      return null;
    }
  }
}
