import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isJourneyActive = false;
  DateTime? _journeyStartTime;

  AppSettings? get settings => _settings;
  List<DayRecord> get records => List.unmodifiable(_records);
  List<Reward> get rewards => List.unmodifiable(_rewards);
  int get currentStreak => _currentStreak;
  CheckInStatus get todayCheckIn => _todayCheckIn;
  bool get isLoading => _isLoading;
  bool get isSetupComplete => _isSetupComplete;
  bool get isJourneyActive => _isJourneyActive;
  DateTime? get journeyStartTime => _journeyStartTime;
  NotificationService get notificationService => _notifications;
  
  DateTime? _testArrivalDeadline;
  
  DateTime? get arrivalDeadline {
    // Use test deadline if set (for testing purposes)
    if (_testArrivalDeadline != null) return _testArrivalDeadline;
    
    if (_settings == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _settings!.arrivalDeadline.hour,
      _settings!.arrivalDeadline.minute,
    );
  }
  
  void setTestDeadline(DateTime deadline) {
    _testArrivalDeadline = deadline;
    _storage.setTestArrivalDeadline(deadline);
    notifyListeners();
  }
  
  void clearTestDeadline() {
    _testArrivalDeadline = null;
    _storage.setTestArrivalDeadline(null);
    notifyListeners();
  }

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
    
    // Load test deadline BEFORE checking journey state (critical for testing!)
    _testArrivalDeadline = await _storage.getTestArrivalDeadline();
    if (_testArrivalDeadline != null) {
      print('🧪 Test deadline loaded from storage: $_testArrivalDeadline');
    }

    // Check if journey should be active (persists across app restarts until arrival time)
    print('🔍 Checking journey state during app initialization...');
    final isJourneyActive = await _storage.isJourneyActive();
    print('🔍 Journey active in storage: $isJourneyActive');
    if (isJourneyActive && _settings != null) {
      final startTime = await _storage.getJourneyStartTime();
      
      // Validate journey and check if it should still be active
      if (startTime != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDate = DateTime(startTime.year, startTime.month, startTime.day);
        
        // Calculate arrival deadline
        final arrivalTime = DateTime(
          now.year,
          now.month,
          now.day,
          _settings!.arrivalDeadline.hour,
          _settings!.arrivalDeadline.minute,
        );
        
        print('🔍 Validating journey: start=$startTime, now=$now');
        print('🔍 Arrival deadline from settings: $arrivalTime');
        print('🔍 Test deadline override: $_testArrivalDeadline');
        
        // Use test deadline if available, otherwise use settings
        final effectiveArrivalTime = _testArrivalDeadline ?? arrivalTime;
        print('🔍 Effective arrival deadline: $effectiveArrivalTime');
        
        // Journey is valid if:
        // 1. Started today
        // 2. Arrival deadline hasn't passed yet (with 30 min grace period)
        final isToday = startDate.isAtSameMomentAs(today);
        final beforeDeadline = now.isBefore(effectiveArrivalTime.add(const Duration(minutes: 30)));
        
        print('🔍 Journey validation: isToday=$isToday, beforeDeadline=$beforeDeadline');
        print('🔍 Now: $now, Deadline+30min: ${effectiveArrivalTime.add(const Duration(minutes: 30))}');
        
        if (isToday && beforeDeadline) {
          _isJourneyActive = true;
          _journeyStartTime = startTime;
          final minutesSinceStart = now.difference(startTime).inMinutes;
          print('🚀 ═══════════════════════════════════════════');
          print('🚀 JOURNEY RESTORED SUCCESSFULLY!');
          print('🚀 _isJourneyActive set to: $_isJourneyActive');
          print('🚀 arrivalDeadline: $arrivalDeadline');
          print('🚀 Started ${minutesSinceStart} min ago');
          print('🚀 ═══════════════════════════════════════════');
          print('✅ COUNTDOWN TIMER SHOULD NOW BE VISIBLE!');
          print('🔍 Calling notifyListeners() to rebuild UI...');
          notifyListeners();
          print('✅ notifyListeners() called - UI should update');
        } else {
          print('⚠️ Journey expired (isToday: $isToday, beforeDeadline: $beforeDeadline), clearing it');
          await _storage.setJourneyActive(false);
          // Clear test deadline if journey expired
          _testArrivalDeadline = null;
          await _storage.setTestArrivalDeadline(null);
        }
      } else {
        print('⚠️ Journey active but no start time found, clearing state');
        await _storage.setJourneyActive(false);
        // Clear test deadline
        _testArrivalDeadline = null;
        await _storage.setTestArrivalDeadline(null);
      }
    }

    if (_settings != null) {
      // Reschedule all notifications and alarms with current settings
      await _notifications.scheduleAllNotifications(_settings!);
      
      // Schedule ALL alarms upfront
      final now = DateTime.now();
      
      var wakeUpDate = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.wakeUpTime.hour,
        _settings!.wakeUpTime.minute,
      );
      if (wakeUpDate.isBefore(now) || wakeUpDate.isAtSameMomentAs(now)) {
        wakeUpDate = wakeUpDate.add(const Duration(days: 1));
      }
      
      var leaveHomeDate = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.leaveHomeTime.hour,
        _settings!.leaveHomeTime.minute,
      );
      // Only push to tomorrow if it's more than 10 seconds in the past
      if (leaveHomeDate.isBefore(now.subtract(const Duration(seconds: 10)))) {
        leaveHomeDate = leaveHomeDate.add(const Duration(days: 1));
      }
      
      var arrivalDeadline = DateTime(
        now.year,
        now.month,
        now.day,
        _settings!.arrivalDeadline.hour,
        _settings!.arrivalDeadline.minute,
      );
      // Only push to tomorrow if it's more than 10 seconds in the past
      if (arrivalDeadline.isBefore(now.subtract(const Duration(seconds: 10)))) {
        arrivalDeadline = arrivalDeadline.add(const Duration(days: 1));
      }
      
      // Override with test deadline if set
      if (_testArrivalDeadline != null) {
        arrivalDeadline = _testArrivalDeadline!;
      }
      
      // Schedule wake-up alarm
      await AlarmService.scheduleWakeUpAlarm(wakeUpDate);
      print('✅ Wake-up alarm scheduled for: $wakeUpDate');
      
      // Schedule checkpoint alarms (every 10 min from wake-up to 5 min before leave)
      await AlarmService.scheduleCheckInAlarms(wakeUpDate, leaveHomeDate);
      
      // Schedule leave-home-soon (5 min before leave)
      await AlarmService.scheduleLeaveHomeSoonAlarm(leaveHomeDate);
      
      // Schedule leave-home alarm
      await AlarmService.scheduleLeaveHomeAlarm(leaveHomeDate);
      
      // Schedule pre-arrival check (2 min before arrival)
      await AlarmService.scheduleArrivalCheckAlarm(arrivalDeadline);
      
      // Schedule arrival alarm (at exact deadline)
      await AlarmService.scheduleArrivalAlarm(arrivalDeadline);
      
      print('✅ All alarms scheduled');
    }

    // List all scheduled notifications on app launch
    await _notifications.listAllScheduledNotifications(_settings);

    _isLoading = false;
    notifyListeners();
  }

  /// Check and restore journey state - called when app resumes from background
  Future<void> checkAndRestoreJourneyState() async {
    print('🔍 ═══════════════════════════════════════════');
    print('🔍 checkAndRestoreJourneyState called');
    print('🔍 ═══════════════════════════════════════════');
    
    // CRITICAL: Reload SharedPreferences to get latest values from background isolate
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    print('🔄 SharedPreferences reloaded to get latest values from alarm isolate');
    
    // Reload test deadline in case it was set during testing
    final testDeadline = await _storage.getTestArrivalDeadline();
    if (testDeadline != null) {
      _testArrivalDeadline = testDeadline;
      print('🧪 Test deadline reloaded from storage: $_testArrivalDeadline');
    }
    
    final isJourneyActive = await _storage.isJourneyActive();
    print('🔍 Journey active flag in storage: $isJourneyActive');
    print('🔍 Current _isJourneyActive state BEFORE: $_isJourneyActive');
    print('🔍 Settings loaded: ${_settings != null}');
    print('🔍 Arrival deadline available: ${arrivalDeadline != null}');
    
    if (isJourneyActive && _settings != null) {
      print('✅ CONDITION MET: Journey active AND settings loaded');
      // Journey is active - restore the countdown state
      final startTime = await _storage.getJourneyStartTime();
      print('🔍 Journey start time from storage: $startTime');
      
      // Validate journey and check if it should still be active
      if (startTime != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDate = DateTime(startTime.year, startTime.month, startTime.day);
        
        // Calculate arrival deadline (use test deadline if set, otherwise settings)
        final settingsArrivalTime = DateTime(
          now.year,
          now.month,
          now.day,
          _settings!.arrivalDeadline.hour,
          _settings!.arrivalDeadline.minute,
        );
        
        final effectiveArrivalTime = _testArrivalDeadline ?? settingsArrivalTime;
        
        print('🔍 Settings arrival deadline: $settingsArrivalTime');
        print('🔍 Test deadline override: $_testArrivalDeadline');
        print('🔍 Effective arrival deadline: $effectiveArrivalTime');
        print('🔍 Current time: $now');
        
        // Journey is valid if started today and arrival deadline hasn't passed
        final isToday = startDate.isAtSameMomentAs(today);
        final beforeDeadline = now.isBefore(effectiveArrivalTime.add(const Duration(minutes: 30)));
        
        print('🔍 Is today: $isToday, Before deadline: $beforeDeadline');
        
        if (isToday && beforeDeadline) {
          _isJourneyActive = true;
          _journeyStartTime = startTime;
          final minutesSinceStart = now.difference(startTime).inMinutes;
          print('🚀 Journey restored from background - starting countdown (started ${minutesSinceStart} min ago)');
          notifyListeners();
        } else {
          print('⚠️ Journey expired (isToday: $isToday, beforeDeadline: $beforeDeadline), clearing it');
          print('⚠️ ABOUT TO CLEAR FLAG - start=$startTime, now=$now, deadline=$effectiveArrivalTime');
          await _storage.setJourneyActive(false);
          print('⚠️ FLAG CLEARED BY checkAndRestoreJourneyState()');
          // Clear test deadline if journey expired
          _testArrivalDeadline = null;
          await _storage.setTestArrivalDeadline(null);
        }
      } else {
        print('⚠️ Journey active but no start time found, clearing state');
        print('⚠️ FLAG WILL BE CLEARED BY checkAndRestoreJourneyState() - NO START TIME');
        await _storage.setJourneyActive(false);
        print('⚠️ FLAG CLEARED');
        // Clear test deadline
        _testArrivalDeadline = null;
        await _storage.setTestArrivalDeadline(null);
      }
    } else if (!isJourneyActive && _isJourneyActive) {
      // Journey was stopped externally
      _isJourneyActive = false;
      _journeyStartTime = null;
      print('🛑 Journey was stopped externally');
      notifyListeners();
    } else {
      print('❌ JOURNEY NOT RESTORED: isJourneyActive=$isJourneyActive, _settings=${_settings != null}');
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _storage.saveSettings(settings);
    await _storage.setSetupComplete(true);
    _isSetupComplete = true;
    
    // Cancel all previous alarms
    await AlarmService.cancelAll();
    
    final now = DateTime.now();
    
    // Schedule ALL alarms upfront
    var wakeUpDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.wakeUpTime.hour,
      settings.wakeUpTime.minute,
    );
    if (wakeUpDate.isBefore(now) || wakeUpDate.isAtSameMomentAs(now)) {
      wakeUpDate = wakeUpDate.add(const Duration(days: 1));
    }
    
    var leaveHomeDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.leaveHomeTime.hour,
      settings.leaveHomeTime.minute,
    );
    // Only push to tomorrow if it's more than 10 seconds in the past
    // (allows test mode to schedule alarms a few seconds in the future)
    if (leaveHomeDate.isBefore(now.subtract(const Duration(seconds: 10)))) {
      leaveHomeDate = leaveHomeDate.add(const Duration(days: 1));
    }
    
    var arrivalDeadline = DateTime(
      now.year,
      now.month,
      now.day,
      settings.arrivalDeadline.hour,
      settings.arrivalDeadline.minute,
    );
    // Only push to tomorrow if it's more than 10 seconds in the past
    if (arrivalDeadline.isBefore(now.subtract(const Duration(seconds: 10)))) {
      arrivalDeadline = arrivalDeadline.add(const Duration(days: 1));
    }
    
    // Override with test deadline if set (for testing)
    if (_testArrivalDeadline != null) {
      arrivalDeadline = _testArrivalDeadline!;
    }
    
    // Schedule wake-up alarm
    await AlarmService.scheduleWakeUpAlarm(wakeUpDate);
    print('✅ Wake-up alarm scheduled for: $wakeUpDate');
    
    // Schedule checkpoint alarms (every 10 min from wake-up to 5 min before leave)
    await AlarmService.scheduleCheckInAlarms(wakeUpDate, leaveHomeDate);
    
    // Schedule leave-home-soon (5 min before leave)
    await AlarmService.scheduleLeaveHomeSoonAlarm(leaveHomeDate);
    
    // Schedule leave-home alarm
    await AlarmService.scheduleLeaveHomeAlarm(leaveHomeDate);
    
    // Schedule pre-arrival check (2 min before arrival)
    await AlarmService.scheduleArrivalCheckAlarm(arrivalDeadline);
    
    // Schedule arrival alarm (at exact deadline)
    await AlarmService.scheduleArrivalAlarm(arrivalDeadline);
    
    print('✅ All alarms scheduled');
    
    notifyListeners();
  }

  Future<void> updateCheckInStatus(CheckInStatus status) async {
    _todayCheckIn = status;
    notifyListeners();
  }

  void startJourney() {
    _isJourneyActive = true;
    _journeyStartTime = DateTime.now();
    _storage.setJourneyActive(true);
    notifyListeners();
  }

  Future<void> stopJourney() async {
    _isJourneyActive = false;
    _journeyStartTime = null;
    await _storage.setJourneyActive(false);
    // Don't auto-clear test deadline here - let caller decide
    print('🛑 Journey stopped and state cleared');
    notifyListeners();
  }

  Future<void> confirmArrival(bool onTime) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Set arrival confirmed flag and cancel Arrival Alarm (ID: 6)
    await _storage.setArrivalConfirmed(true);
    await AlarmService.cancelArrivalAlarm();
    print('✅ Arrival confirmed - Arrival Alarm (ID: 6) cancelled');

    // Stop the journey
    await stopJourney();
    
    // Clear test deadline after stopping journey
    clearTestDeadline();

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
    // Note: Journey is started by Leave Home Alarm (ID: 4), not by user response
    // This method is no longer called since checkpoint alarms don't have action buttons
    
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
