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
import '../services/analytics_service.dart';
import '../services/localization_helper.dart';

enum JourneyPhase { idle, gettingReady, onTheWay }

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
  bool _isOnboardingComplete = false;
  bool _arrivalConfirmedToday = false;

  AppSettings? get settings => _settings;
  List<DayRecord> get records => List.unmodifiable(_records);
  List<Reward> get rewards => List.unmodifiable(_rewards);
  int get currentStreak => _currentStreak;
  CheckInStatus get todayCheckIn => _todayCheckIn;
  bool get isLoading => _isLoading;
  bool get isSetupComplete => _isSetupComplete;
  bool get isOnboardingComplete => _isOnboardingComplete;
  
  // Get the current active reward (single reward system)
  Reward? get currentReward {
    try {
      return _rewards.firstWhere((r) => r.isActive);
    } catch (e) {
      return null;
    }
  }

  Reward? get latestCompletedReward {
    final completed = _rewards
        .where((r) => r.completionDate != null)
        .toList()
      ..sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

    if (completed.isEmpty) return null;
    return completed.first;
  }

  bool hasRewardAchievementOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _rewards.any((reward) {
      final completedAt = reward.completionDate;
      if (completedAt == null) return false;
      final completedDate = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      return completedDate.isAtSameMomentAs(targetDate);
    });
  }
  
  // Pure time-based computation - no state needed!
  bool get isJourneyActive {
    if (_settings == null) return false;
    
    // If arrival already confirmed today, journey is over
    if (_arrivalConfirmedToday) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get leave time for today
    var leaveTime = DateTime(
      today.year,
      today.month,
      today.day,
      _settings!.leaveHomeTime.hour,
      _settings!.leaveHomeTime.minute,
    );
    
    // Get arrival time - use test deadline if set, otherwise calculate from settings
    var arrivalTime = _testArrivalDeadline;
    if (arrivalTime == null) {
      arrivalTime = DateTime(
        today.year,
        today.month,
        today.day,
        _settings!.arrivalDeadline.hour,
        _settings!.arrivalDeadline.minute,
      );
      
      // If arrival hour is less than leave hour, journey crosses midnight (arrival is tomorrow)
      if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
          (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
           _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
        arrivalTime = arrivalTime.add(const Duration(days: 1));
      }
    }
    
    // Check if we're in an active journey
    final inJourney = (now.isAfter(leaveTime) || now.isAtSameMomentAs(leaveTime)) && now.isBefore(arrivalTime);
    
    // If not in journey with today's times, check if we're in yesterday's journey
    // (handles case where we're past midnight but journey started yesterday)
    if (!inJourney && now.hour < 6) { // Only check yesterday if we're in early morning hours
      final yesterday = today.subtract(const Duration(days: 1));
      var yesterdayLeave = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        _settings!.leaveHomeTime.hour,
        _settings!.leaveHomeTime.minute,
      );
      
      var yesterdayArrival = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        _settings!.arrivalDeadline.hour,
        _settings!.arrivalDeadline.minute,
      );
      
      // If arrival hour is less than leave hour, arrival is next day
      if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
          (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
           _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
        yesterdayArrival = yesterdayArrival.add(const Duration(days: 1));
      }
      
      return (now.isAfter(yesterdayLeave) || now.isAtSameMomentAs(yesterdayLeave)) && now.isBefore(yesterdayArrival);
    }
    
    return inJourney;
  }

  /// Three-state journey model: idle, gettingReady, onTheWay
  JourneyPhase get currentJourneyPhase {
    if (_settings == null) return JourneyPhase.idle;
    if (_arrivalConfirmedToday) return JourneyPhase.idle;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Idle if today is not an active day (unless test deadline is set)
    if (_testArrivalDeadline == null && !_settings!.isActiveOnDate(today)) {
      return JourneyPhase.idle;
    }

    // Calculate wake-up, leave, and arrival times for today
    var wakeUpTime = DateTime(
      today.year, today.month, today.day,
      _settings!.wakeUpTime.hour, _settings!.wakeUpTime.minute,
    );
    var leaveTime = DateTime(
      today.year, today.month, today.day,
      _settings!.leaveHomeTime.hour, _settings!.leaveHomeTime.minute,
    );
    var arrivalTime = _testArrivalDeadline;
    if (arrivalTime == null) {
      arrivalTime = DateTime(
        today.year, today.month, today.day,
        _settings!.arrivalDeadline.hour, _settings!.arrivalDeadline.minute,
      );
      if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
          (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
           _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
        arrivalTime = arrivalTime.add(const Duration(days: 1));
      }
    }

    // Handle leave time crossing midnight relative to wake-up
    if (leaveTime.isBefore(wakeUpTime) || leaveTime.isAtSameMomentAs(wakeUpTime)) {
      leaveTime = leaveTime.add(const Duration(days: 1));
    }

    // Check today's times
    final afterWakeUp = now.isAfter(wakeUpTime) || now.isAtSameMomentAs(wakeUpTime);
    final beforeLeave = now.isBefore(leaveTime);
    final afterLeave = now.isAfter(leaveTime) || now.isAtSameMomentAs(leaveTime);
    final beforeArrival = now.isBefore(arrivalTime);

    if (afterWakeUp && beforeLeave) return JourneyPhase.gettingReady;
    if (afterLeave && beforeArrival) return JourneyPhase.onTheWay;

    // Check yesterday's journey for early morning hours
    if (now.hour < 6) {
      final yesterday = today.subtract(const Duration(days: 1));
      var yWakeUp = DateTime(yesterday.year, yesterday.month, yesterday.day,
        _settings!.wakeUpTime.hour, _settings!.wakeUpTime.minute);
      var yLeave = DateTime(yesterday.year, yesterday.month, yesterday.day,
        _settings!.leaveHomeTime.hour, _settings!.leaveHomeTime.minute);
      var yArrival = DateTime(yesterday.year, yesterday.month, yesterday.day,
        _settings!.arrivalDeadline.hour, _settings!.arrivalDeadline.minute);

      if (yLeave.isBefore(yWakeUp) || yLeave.isAtSameMomentAs(yWakeUp)) {
        yLeave = yLeave.add(const Duration(days: 1));
      }
      if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
          (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
           _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
        yArrival = yArrival.add(const Duration(days: 1));
      }

      final yAfterWakeUp = now.isAfter(yWakeUp) || now.isAtSameMomentAs(yWakeUp);
      final yBeforeLeave = now.isBefore(yLeave);
      final yAfterLeave = now.isAfter(yLeave) || now.isAtSameMomentAs(yLeave);
      final yBeforeArrival = now.isBefore(yArrival);

      if (yAfterWakeUp && yBeforeLeave) return JourneyPhase.gettingReady;
      if (yAfterLeave && yBeforeArrival) return JourneyPhase.onTheWay;
    }

    return JourneyPhase.idle;
  }

  /// Get today's wake-up time as DateTime (for progress calculations)
  DateTime? get todayWakeUpTime {
    if (_settings == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(
      today.year, today.month, today.day,
      _settings!.wakeUpTime.hour, _settings!.wakeUpTime.minute,
    );
  }

  /// Get today's leave-home time as DateTime
  DateTime? get todayLeaveTime {
    if (_settings == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var leaveTime = DateTime(
      today.year, today.month, today.day,
      _settings!.leaveHomeTime.hour, _settings!.leaveHomeTime.minute,
    );
    // Handle leave crossing midnight relative to wake-up
    final wakeUpTime = DateTime(
      today.year, today.month, today.day,
      _settings!.wakeUpTime.hour, _settings!.wakeUpTime.minute,
    );
    if (leaveTime.isBefore(wakeUpTime) || leaveTime.isAtSameMomentAs(wakeUpTime)) {
      leaveTime = leaveTime.add(const Duration(days: 1));
    }
    return leaveTime;
  }

  /// Last notification message written by alarm callbacks
  String _lastJourneyNotification = '';
  int _lastJourneyNotificationTime = 0;

  String get lastJourneyNotification => _lastJourneyNotification;

  /// Reload last journey notification from SharedPreferences.
  /// Must call prefs.reload() because alarm callbacks write from a
  /// separate background isolate whose writes bypass the in-memory cache.
  Future<void> refreshLastJourneyNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final message = prefs.getString('last_journey_notification') ?? '';
    final time = prefs.getInt('last_journey_notification_time') ?? 0;
    if (time != _lastJourneyNotificationTime) {
      _lastJourneyNotification = message;
      _lastJourneyNotificationTime = time;
      notifyListeners();
    }
  }

  NotificationService get notificationService => _notifications;
  
  DateTime? _testArrivalDeadline;
  
  DateTime? get arrivalDeadline {
    // Use test deadline if set (for testing purposes)
    if (_testArrivalDeadline != null) return _testArrivalDeadline;
    
    if (_settings == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    var deadline = DateTime(
      today.year,
      today.month,
      today.day,
      _settings!.arrivalDeadline.hour,
      _settings!.arrivalDeadline.minute,
    );
    
    // If arrival hour is less than leave hour, journey crosses midnight (arrival is tomorrow)
    if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
        (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
         _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
      deadline = deadline.add(const Duration(days: 1));
    }
    
    // If we're in early morning and the calculated deadline is in the future,
    // check if we should use yesterday's deadline (for journeys that started yesterday)
    if (now.hour < 6 && deadline.isAfter(now.add(const Duration(hours: 18)))) {
      // Deadline is more than 18 hours in the future, likely should be yesterday's
      final yesterday = today.subtract(const Duration(days: 1));
      var yesterdayDeadline = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        _settings!.arrivalDeadline.hour,
        _settings!.arrivalDeadline.minute,
      );
      
      // If arrival hour is less than leave hour, add a day
      if (_settings!.arrivalDeadline.hour < _settings!.leaveHomeTime.hour ||
          (_settings!.arrivalDeadline.hour == _settings!.leaveHomeTime.hour &&
           _settings!.arrivalDeadline.minute < _settings!.leaveHomeTime.minute)) {
        yesterdayDeadline = yesterdayDeadline.add(const Duration(days: 1));
      }
      
      // Use yesterday's deadline if it's in the future
      if (yesterdayDeadline.isAfter(now)) {
        return yesterdayDeadline;
      }
    }
    
    return deadline;
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
    
    // Load onboarding status first
    _isOnboardingComplete = await _storage.isOnboardingComplete();
    
    // Only request permissions if onboarding is complete
    // (Onboarding screen handles permission requests for first-time users)
    if (_isOnboardingComplete) {
      await _notifications.requestPermissions();
    }
    
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

    // Flush any analytics events queued from background isolates
    await AnalyticsService.flushDeferredEvents();

    _settings = await _storage.loadSettings();
    _records = await _storage.loadRecords();
    _rewards = await _storage.loadRewards();
    _currentStreak = _streakService.calculateCurrentStreak(_records);
    _isSetupComplete = await _storage.isSetupComplete();
    // _isOnboardingComplete already loaded above before permission request
    
    // Initialize default reward if no rewards exist
    if (_rewards.isEmpty) {
      // Get localized default reward name
      final localizedRewardName = await LocalizationHelper.getDefaultRewardName();
      final defaultReward = Reward.defaultReward(name: localizedRewardName);
      _rewards.add(defaultReward);
      await _storage.saveRewards(_rewards);
      print('🎁 Created default reward: ${defaultReward.name}');
    }
    
    // Load test deadline BEFORE checking journey state (critical for testing!)
    _testArrivalDeadline = await _storage.getTestArrivalDeadline();
    if (_testArrivalDeadline != null) {
      print('🧪 Test deadline loaded from storage: $_testArrivalDeadline');
    }
    
    // Check if arrival was already confirmed today
    final arrivalConfirmed = await _storage.getArrivalConfirmed();
    _arrivalConfirmedToday = arrivalConfirmed;
    if (_arrivalConfirmedToday) {
      print('✅ Arrival already confirmed today - journey inactive');
    }

    // Journey state is now computed on-demand from current time vs leave/arrival times
    print('🔍 Journey status will be computed automatically based on current time');

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
      
      // === 7-DAY ROLLING WINDOW SCHEDULING ===
      // Instead of scheduling individual alarms, use the new 7-day rolling window approach
      print('🗓️  Scheduling 7-day rolling window...');
      await AlarmService.scheduleAlarmsFor7Days(_settings!);
      print('✅ 7-day rolling window scheduled');
    }

    // List all scheduled notifications on app launch
    await _notifications.listAllScheduledNotifications(_settings);

    _isLoading = false;
    notifyListeners();
  }

  /// Check and restore journey state - called when app resumes from background
  /// Now simplified: just reload test deadline and trigger UI update
  Future<void> checkAndRestoreJourneyState() async {
    print('🔍 Checking journey state (time-based computation)...');
    
    // Reload test deadline in case it was set during testing
    final testDeadline = await _storage.getTestArrivalDeadline();
    if (testDeadline != null) {
      _testArrivalDeadline = testDeadline;
      print('🧪 Test deadline loaded: $_testArrivalDeadline');
    }
    
    // Sync arrival confirmation from SharedPreferences
    // (background alarm isolate may have reset it)
    final arrivalConfirmed = await _storage.getArrivalConfirmed();
    if (_arrivalConfirmedToday != arrivalConfirmed) {
      print('🔄 Synced arrival_confirmed: $_arrivalConfirmedToday → $arrivalConfirmed');
      _arrivalConfirmedToday = arrivalConfirmed;
    }
    
    // isJourneyActive is now a computed getter - no state to restore!
    print('🔍 Journey active (computed): $isJourneyActive');
    print('🔍 Current time vs leave/arrival: ${DateTime.now()}');
    
    // Just trigger UI update - countdown will appear if time is right
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _storage.saveSettings(settings);
    await _storage.setSetupComplete(true);
    _isSetupComplete = true;
    
    final now = DateTime.now();
    
    // Reset arrival confirmation — new settings mean a new journey,
    // so a previous journey's confirmation should not block it
    _arrivalConfirmedToday = false;
    await _storage.setArrivalConfirmed(false);
    
    // Clear today's day record so the new journey starts fresh
    // (prevents a previous journey's result from persisting)
    final todayDate = DateTime(now.year, now.month, now.day);
    _records.removeWhere((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate.isAtSameMomentAs(todayDate);
    });
    await _storage.saveRecords(_records);
    // Note: don't recalculate streak here — removing today's record is just
    // clearing stale UI state. The streak will be recalculated when the new
    // journey completes (in confirmArrival / markMissionFailed).
    
    // Clear test deadline if this is NOT a test save (test save = deadline set within last 30 sec)
    // This ensures that changing settings cancels any ongoing test journey
    if (_testArrivalDeadline != null) {
      final deadlineAge = _testArrivalDeadline!.difference(now).inSeconds;
      // If deadline is more than 30 seconds in the future or in the past, clear it (not a fresh test)
      if (deadlineAge < 10 || deadlineAge > 1200) { // Keep only if 10 sec < deadline < 20 min
        print('🧹 Clearing stale test deadline (was: $_testArrivalDeadline)');
        _testArrivalDeadline = null;
        await _storage.setTestArrivalDeadline(null);
        notifyListeners(); // Trigger journey state recalculation
      } else {
        print('🧪 Keeping fresh test deadline: $_testArrivalDeadline (test in progress)');
      }
    }
    
    // Cancel all previous alarms
    await AlarmService.cancelAll();
    
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
    
    // === 7-DAY ROLLING WINDOW SCHEDULING ===
    // Instead of scheduling individual alarms, use the new 7-day rolling window approach
    print('🗓️  Scheduling 7-day rolling window...');
    await AlarmService.scheduleAlarmsFor7Days(settings);
    print('✅ 7-day rolling window scheduled');
    
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await _storage.setOnboardingComplete(true);
    notifyListeners();
  }

  Future<void> updateCheckInStatus(CheckInStatus status) async {
    _todayCheckIn = status;
    notifyListeners();
  }

  Future<void> resetArrivalConfirmation() async {
    _arrivalConfirmedToday = false;
    await _storage.setArrivalConfirmed(false);
    notifyListeners();
  }

  // Journey start/stop removed - now purely time-based!
  // Journey is automatically "active" when current time is between leave time and arrival time

  Future<void> confirmArrival(bool onTime) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Set arrival confirmed flag and cancel all arrival-related alarms (IDs: 5, 7, 8, 6)
    await _storage.setArrivalConfirmed(true);
    _arrivalConfirmedToday = true; // Update local state immediately
    await AlarmService.cancelArrivalAlarm();
    print('✅ Arrival confirmed - Pre-arrival (IDs: 5, 7, 8) & Arrival (ID: 6) cancelled');
    
    // Clear test deadline (journey will auto-stop based on confirmation)
    clearTestDeadline();

    // Handle failure case using shared helper
    if (!onTime) {
      // Log analytics before resetting streak
      await AnalyticsService.logJourneyCompleted(onTime: false);
      await AnalyticsService.logStreakBroken(streakLengthBeforeReset: _currentStreak);

      // Use shared logic to mark mission as failed (skip analytics — already logged above)
      await AlarmService.markMissionFailed(skipAnalytics: true);
      
      // Reload local state from storage
      _records = await _storage.loadRecords();
      _currentStreak = 0; // Streak was reset by markMissionFailed
      
      // Play failure message
      await _voice.playFailureMessage();
      
      // Reset check-in for next day
      _todayCheckIn = CheckInStatus.notStarted;
      
      notifyListeners();
      return;
    }

    // Handle success case (onTime = true)
    final existingIndex = _records.indexWhere((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate.isAtSameMomentAs(todayDate);
    });

    final newRecord = DayRecord(
      date: todayDate,
      wasOnTime: true,
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

    // Log analytics for successful arrival
    await AnalyticsService.logJourneyCompleted(onTime: true);
    await AnalyticsService.logStreakUpdated(streakLength: _currentStreak);

    // Play success message and handle rewards
    if (onTime) {
      await _voice.playSuccessMessage(_currentStreak);
      
      // Check if reward is achieved
      final reward = currentReward;
      if (reward != null && reward.isAchieved(_currentStreak)) {
        print('🎉 Reward achieved: ${reward.name}');
        // Reward celebration will be handled in the UI
        // Mark reward as completed after a short delay to show celebration first
        Future.delayed(const Duration(seconds: 2), () async {
          await markRewardAsCompleted();
        });
      }
      
      // Check for reward eligibility
      final nextReward = _getNextReward();
      if (nextReward != null) {
        final daysRemaining = nextReward.requiredStreakLength - _currentStreak;
        if (daysRemaining >= 0 && daysRemaining <= 2) {
          await _voice.playRewardMessage(nextReward.name, daysRemaining);
        }
      }
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

  // Update the current active reward
  Future<void> updateCurrentReward({required String name, required int requiredStreak}) async {
    final current = currentReward;
    if (current != null) {
      final updated = current.copyWith(
        name: name,
        requiredStreakLength: requiredStreak,
      );
      await updateReward(current.id, updated);
    } else {
      // Create new reward if none exists
      final newReward = Reward(
        id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        requiredStreakLength: requiredStreak,
        creationDate: DateTime.now(),
        isActive: true,
      );
      await addReward(newReward);
    }
  }

  // Mark current reward as completed
  Future<void> markRewardAsCompleted() async {
    final current = currentReward;
    if (current != null && current.isAchieved(_currentStreak)) {
      final completed = current.copyWith(
        completionDate: DateTime.now(),
        isActive: false,
      );
      await updateReward(current.id, completed);
      print('🏆 Reward completed: ${current.name}');
    }
  }

  Future<bool> forceCompleteCurrentRewardForTesting() async {
    final current = currentReward;
    if (current == null) return false;

    final required = current.requiredStreakLength;
    if (_currentStreak < required) {
      _currentStreak = required;
      await _storage.setCurrentStreak(_currentStreak);
    }

    await markRewardAsCompleted();
    notifyListeners();
    return true;
  }

  // Reset reward progress (when streak resets)
  Future<void> resetRewardProgress() async {
    // Reward stays active, just the progress resets with the streak
    // No changes needed to the reward itself
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
