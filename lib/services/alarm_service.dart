import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_helper.dart';
import '../models/app_settings.dart';

// Top-level callback function - must be static or top-level
@pragma('vm:entry-point')
void alarmCallback() async {
  print('🚨 WAKE-UP ALARM FIRED!');
  
  // Reset arrival confirmation flag for new day
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('arrival_confirmed', false);
  print('🔄 Reset arrival_confirmed flag for new day');
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final wakeUpMessage = await LocalizationHelper.getWakeUpMessage();
  final wakeUpTitle = await LocalizationHelper.getWakeUpTitle();
  
  // Initialize TTS for voice message
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  
  // Speak the wake-up message
  await tts.speak(wakeUpMessage);
  
  // Show notification immediately when alarm fires
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    channelDescription: 'Wake-up and reminder notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    1,
    wakeUpTitle,
    wakeUpMessage,
    notificationDetails,
  );
  
  print('✅ Wake-up notification shown');
  
  // === 7-DAY ROLLING WINDOW EXTENSION ===
  // Extend the 7-day window by scheduling day 8 alarms
  try {
    // Load settings from SharedPreferences
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettings.fromJson(settingsMap);
      
      // Calculate day 8 date (7 days from now)
      final now = DateTime.now();
      final day8Date = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
      
      // Check if day 8 is active (weekday is in activeDaysOfWeek)
      if (settings.isActiveOnDate(day8Date)) {
        print('🗓️  Extending 7-day window: Scheduling day 8 (${AlarmService._formatDate(day8Date)})...');
        
        // Calculate alarm times for day 8
        final day8WakeUp = DateTime(
          day8Date.year,
          day8Date.month,
          day8Date.day,
          settings.wakeUpTime.hour,
          settings.wakeUpTime.minute,
        );
        
        final day8Leave = DateTime(
          day8Date.year,
          day8Date.month,
          day8Date.day,
          settings.leaveHomeTime.hour,
          settings.leaveHomeTime.minute,
        );
        
        final day8Arrival = DateTime(
          day8Date.year,
          day8Date.month,
          day8Date.day,
          settings.arrivalDeadline.hour,
          settings.arrivalDeadline.minute,
        );
        
        // Schedule all alarms for day 8 with dayOffset = 7
        final scheduledCount = await AlarmService._scheduleAllAlarmsForDate(
          dayOffset: 7,
          wakeUpTime: day8WakeUp,
          leaveHomeTime: day8Leave,
          arrivalDeadline: day8Arrival,
          minutesBeforeLeaving1: settings.minutesBeforeLeaving1,
          minutesBeforeLeaving2: settings.minutesBeforeLeaving2,
          minutesBeforeArrival: settings.minutesBeforeArrival,
        );
        
        print('✅ Day 8 scheduled: $scheduledCount alarms added to rolling window');
      } else {
        print('⏭️  Day 8 (${AlarmService._formatDate(day8Date)}): SKIPPED (inactive day)');
      }
    } else {
      print('⚠️  No settings found - cannot extend 7-day window');
    }
  } catch (e) {
    print('❌ Error extending 7-day window: $e');
  }
}

// Helper function to schedule checkpoint alarms from wake-up callback
@pragma('vm:entry-point')
void testAlarmCallback() async {
  print('🧪 TEST ALARM FIRED!');
  
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    999,
    '🧪 TEST ALARM SUCCESS!',
    'The AlarmManager approach works! This fired from background.',
    notificationDetails,
  );
  
  print('✅ Test notification shown from alarm callback');
}

// Checkpoint alarms fire every 10 minutes - these don't auto-reschedule
// They only play TTS with no notification UI
@pragma('vm:entry-point')
void checkInAlarmCallback() async {
  print('⏰ CHECKPOINT ALARM FIRED!');
  
  final now = DateTime.now();
  
  // Get leave home time from settings to calculate minutes remaining
  final prefs = await SharedPreferences.getInstance();
  final settingsJson = prefs.getString('app_settings');
  
  int minutesLeft = 0;
  if (settingsJson != null) {
    try {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettings.fromJson(settingsMap);
      
      final leaveTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        settings.leaveHomeTime.hour, 
        settings.leaveHomeTime.minute
      );
      minutesLeft = leaveTime.difference(now).inMinutes;
      
      // If already past leave time, don't play
      if (minutesLeft <= 0) {
        print('⚠️ Skipping checkpoint - already past leave time');
        return;
      }
    } catch (e) {
      print('❌ Could not parse leave time from settings: $e');
      return;
    }
  } else {
    print('❌ No settings found, skipping checkpoint');
    return;
  }
  
  // Get localized language
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  
  // Build dynamic message with minutes left
  final String message;
  if (ttsLanguage == 'es-ES') {
    message = '¡Oye! ¿Cómo van las cosas? Tenemos $minutesLeft minutos para salir';
  } else {
    message = 'Hey! How are things going? We have $minutesLeft minutes left to go';
  }
  
  // Initialize TTS and speak
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  await tts.speak(message);
  
  print('✅ Checkpoint TTS played: "$message"');
  // Note: Checkpoint alarms don't auto-reschedule, they're scheduled fresh each day
}

@pragma('vm:entry-point')
void leaveHomeSoonCallback() async {
  print('🏃 LEAVE HOME SOON ALARM FIRED!');
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final leaveHomeSoonMessage = await LocalizationHelper.getLeaveHomeSoonMessage();
  final leaveHomeSoonTitle = await LocalizationHelper.getLeaveHomeSoonTitle();
  
  // Initialize TTS for voice message
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  
  // Speak the urgent message
  await tts.speak(leaveHomeSoonMessage);
  
  // Show notification
  final notifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    channelDescription: 'Wake-up and reminder notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    3,
    leaveHomeSoonTitle,
    leaveHomeSoonMessage,
    notificationDetails,
  );
  
  print('✅ Leave home soon notification shown');
  
  // Reschedule for tomorrow
  final now = DateTime.now();
  final tomorrow = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  ).add(const Duration(days: 1));
  
  await AndroidAlarmManager.oneShotAt(
    tomorrow,
    3,
    leaveHomeSoonCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
  
  print('✅ Leave home soon rescheduled for tomorrow: $tomorrow');
}

@pragma('vm:entry-point')
void leaveHomeCallback() async {
  print('🚪 LEAVE HOME ALARM FIRED!');
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final leaveHomeNowMessage = await LocalizationHelper.getLeaveHomeNowMessage();
  final leaveHomeNowTitle = await LocalizationHelper.getLeaveHomeNowTitle();
  
  // Initialize TTS for voice message
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  
  // Speak the urgent message
  await tts.speak(leaveHomeNowMessage);
  
  // No need to set journey flag - countdown now computed purely from time!
  print('🚀 Leave home time reached - countdown will appear automatically');
  
  // Show notification with countdown-style message
  final notifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    channelDescription: 'Wake-up and reminder notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
    ongoing: true, // Make it persistent during journey
    autoCancel: false,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    4,
    '🚀 Journey Started!',
    '$leaveHomeNowMessage Open app to see countdown timer.',
    notificationDetails,
    payload: 'leave_home', // Add payload to identify this notification
  );
  
  print('✅ Leave home notification shown with journey started message');
  
  // Reschedule for tomorrow
  final now = DateTime.now();
  final tomorrow = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  ).add(const Duration(days: 1));
  
  await AndroidAlarmManager.oneShotAt(
    tomorrow,
    4,
    leaveHomeCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
  
  print('✅ Leave home rescheduled for tomorrow: $tomorrow');
}

@pragma('vm:entry-point')
void arrivalCheckCallback() async {
  print('🎯 ARRIVAL CHECK ALARM FIRED!');
  
  // Get localized messages
  final arrivalCheckTitle = await LocalizationHelper.getArrivalCheckTitle();
  final arrivalCheckBody = await LocalizationHelper.getArrivalCheckBody();
  final arrivedYesText = await LocalizationHelper.getArrivedYesText();
  // Note: 'No' button removed per PRD - user can only confirm arrival
  
  // Show notification with single action button
  final notifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    channelDescription: 'Wake-up and reminder notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
    actions: [
      AndroidNotificationAction(
        'arrived_yes',
        arrivedYesText,
        showsUserInterface: true,
      ),
    ],
  );
  
  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    5,
    arrivalCheckTitle,
    arrivalCheckBody,
    notificationDetails,
  );
  
  print('✅ Arrival check notification shown');
  
  // Reschedule for tomorrow
  final now = DateTime.now();
  final tomorrow = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  ).add(const Duration(days: 1));
  
  await AndroidAlarmManager.oneShotAt(
    tomorrow,
    5,
    arrivalCheckCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
  
  print('✅ Arrival check rescheduled for tomorrow: $tomorrow');
}

// Arrival Alarm (ID: 6) - fires at exact arrival deadline
// Only fires if user hasn't confirmed arrival via Pre-Arrival Check
@pragma('vm:entry-point')
void arrivalAlarmCallback() async {
  print('⌛ ARRIVAL ALARM FIRED at deadline!');
  
  // Check if arrival was already confirmed
  final prefs = await SharedPreferences.getInstance();
  final arrivalConfirmed = prefs.getBool('arrival_confirmed') ?? false;
  
  if (arrivalConfirmed) {
    print('✅ Arrival already confirmed - skipping alarm');
    return;
  }
  
  print('❌ Arrival NOT confirmed - marking day as missed');
  
  // Get localized language for TTS and notification
  final locale = await LocalizationHelper.getLocale();
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final String title;
  final String body;
  final String ttsMessage;
  
  if (locale == 'es') {
    title = '⌛ ¡Se acabó el tiempo!';
    body = 'No llegamos a tiempo hoy';
    ttsMessage = 'Lo sentimos, no llegamos a tiempo hoy';
  } else {
    title = '⌛ Time is up!';
    body = 'We did not arrive on time today';
    ttsMessage = 'Sorry, you did not make it today';
  }
  
  // Play TTS message
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  await tts.speak(ttsMessage);
  print('🔊 TTS message played: $ttsMessage');
  
  // Show notification
  final notifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);
  
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'morning_alarms',
    'Morning Alarms',
    channelDescription: 'Wake-up and reminder notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    6,
    title,
    body,
    notificationDetails,
  );
  
  // Mark today as missed
  final today = DateTime.now();
  final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  await prefs.setString('day_$dateKey', 'missed');
  
  // Reset streak
  await prefs.setInt('current_streak', 0);
  
  print('✅ Day marked as missed, streak reset');
  
  // Do NOT reschedule - this alarm is scheduled fresh each day when Pre-Arrival Check fires
}

class AlarmService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    print('✅ AlarmManager initialized');
  }
  
  static Future<void> scheduleTestAlarm() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 1));
    
    print('⏰ Scheduling AlarmManager test for: $testTime (in 1 minute)');
    
    await AndroidAlarmManager.oneShotAt(
      testTime,
      999, // Unique ID for test alarm
      testAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
    );
    
    print('✅ AlarmManager test scheduled');
  }
  
  static Future<void> scheduleWakeUpAlarm(DateTime wakeUpTime) async {
    final now = DateTime.now();
    
    // If the wake-up time is in the past today, schedule for tomorrow
    var nextWakeUp = wakeUpTime;
    if (nextWakeUp.isBefore(now)) {
      nextWakeUp = nextWakeUp.add(const Duration(days: 1));
    }
    
    print('⏰ Scheduling next wake-up alarm for: $nextWakeUp');
    
    // Schedule the next wake-up as a one-shot alarm
    // When it fires, it will reschedule itself for the next day
    await AndroidAlarmManager.oneShotAt(
      nextWakeUp,
      1, // Unique ID for wake-up alarm
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Wake-up alarm scheduled (will auto-repeat daily)');
  }
  
  // Schedule multiple checkpoint alarms every 10 minutes
  // from wake-up time until 5 minutes before leave time
  static Future<void> scheduleCheckInAlarms(
    DateTime wakeUpTime,
    DateTime leaveHomeTime,
  ) async {
    final now = DateTime.now();
    
    // Calculate the cutoff time (5 minutes before leave)
    final cutoffTime = leaveHomeTime.subtract(const Duration(minutes: 5));
    
    // Start scheduling checkpoints 10 minutes after wake-up
    DateTime nextCheckIn = wakeUpTime.add(const Duration(minutes: 10));
    
    int alarmId = 100; // Start checkpoint IDs at 100
    int scheduledCount = 0;
    
    while (nextCheckIn.isBefore(cutoffTime)) {
      // Skip alarms in the past OR too close to now (within 2 minutes)
      // to prevent immediate triggering
      final timeUntilAlarm = nextCheckIn.difference(now);
      if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 2) {
        print('⏰ Skipping checkpoint alarm (time already passed or too soon): $nextCheckIn');
        nextCheckIn = nextCheckIn.add(const Duration(minutes: 10));
        alarmId++;
        continue;
      }
      
      print('⏰ Scheduling checkpoint alarm #${scheduledCount + 1} for: $nextCheckIn (in ${timeUntilAlarm.inMinutes} minutes)');
      
      await AndroidAlarmManager.oneShotAt(
        nextCheckIn,
        alarmId,
        checkInAlarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      scheduledCount++;
      
      // Move to next checkpoint (10 minutes later)
      nextCheckIn = nextCheckIn.add(const Duration(minutes: 10));
      alarmId++;
      
      // Safety limit: max 20 checkpoint alarms per day
      if (alarmId >= 120) break;
    }
    
    if (scheduledCount == 0) {
      print('✅ No checkpoint alarms scheduled (all times have passed or too soon for today)');
    } else {
      print('✅ Scheduled $scheduledCount checkpoint alarm(s)');
    }
  }
  
  static Future<void> scheduleLeaveHomeSoonAlarm(DateTime leaveHomeTime) async {
    final now = DateTime.now();
    
    // 5 minutes before leave home time
    final alarmTime = leaveHomeTime.subtract(const Duration(minutes: 5));
    
    // Skip if in the past or too close to now (within 2 minutes)
    final timeUntilAlarm = alarmTime.difference(now);
    if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 2) {
      print('⏰ Skipping leave-home-soon alarm (time already passed or too soon): $alarmTime');
      return;
    }
    
    print('⏰ Scheduling leave-home-soon alarm for: $alarmTime (in ${timeUntilAlarm.inMinutes} minutes)');
    
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      3, // Unique ID for leave-home-soon alarm
      leaveHomeSoonCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Leave-home-soon alarm scheduled');
  }
  
  static Future<void> scheduleLeaveHomeAlarm(DateTime leaveHomeTime) async {
    final now = DateTime.now();
    
    // Calculate time until alarm
    final timeUntilAlarm = leaveHomeTime.difference(now);
    
    // Allow very short intervals for testing (as low as 1 second)
    if (timeUntilAlarm.isNegative) {
      print('⏰ Cannot schedule leave-home alarm in the past: $leaveHomeTime');
      return;
    }
    
    // For test alarms (< 1 minute), use a different alarm ID to avoid conflicts
    final isTestAlarm = timeUntilAlarm.inMinutes < 1;
    final alarmId = isTestAlarm ? 998 : 4;
    
    print('⏰ Scheduling leave-home alarm for: $leaveHomeTime (in ${timeUntilAlarm.inSeconds} seconds)');
    
    await AndroidAlarmManager.oneShotAt(
      leaveHomeTime,
      alarmId, // Use test ID for short alarms, regular ID for normal schedule
      leaveHomeCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: !isTestAlarm, // Don't reschedule test alarms on reboot
    );
    
    print('✅ Leave-home alarm scheduled${isTestAlarm ? ' (TEST MODE)' : ''}');
  }
  
  static Future<void> scheduleArrivalCheckAlarm(DateTime arrivalTime) async {
    final now = DateTime.now();
    
    // 2 minutes before arrival time
    final alarmTime = arrivalTime.subtract(const Duration(minutes: 2));
    
    // Skip if in the past or too close to now (within 30 seconds for test mode)
    final timeUntilAlarm = alarmTime.difference(now);
    if (timeUntilAlarm.isNegative || timeUntilAlarm.inSeconds < 30) {
      print('⏰ Skipping arrival-check alarm (time already passed or too soon): $alarmTime');
      return;
    }
    
    print('⏰ Scheduling arrival-check alarm for: $alarmTime (in ${timeUntilAlarm.inMinutes} minutes)');
    
    // Reset arrival confirmation flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('arrival_confirmed', false);
    print('🔄 Reset arrival_confirmed flag to false');
    
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      5, // Unique ID for arrival-check alarm
      arrivalCheckCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Arrival-check alarm scheduled');
    
    // Also schedule Arrival Alarm (ID: 6) at exact deadline
    await scheduleArrivalAlarm(arrivalTime);
  }
  
  static Future<void> scheduleArrivalAlarm(DateTime arrivalTime) async {
    final now = DateTime.now();
    
    // Skip if in the past or too close to now (within 1 minute)
    final timeUntilAlarm = arrivalTime.difference(now);
    if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 1) {
      print('⏰ Skipping arrival alarm (time already passed or too soon): $arrivalTime');
      return;
    }
    
    print('⏰ Scheduling arrival alarm (ID: 6) for: $arrivalTime (in ${timeUntilAlarm.inMinutes} minutes)');
    
    await AndroidAlarmManager.oneShotAt(
      arrivalTime,
      6, // Unique ID for arrival alarm
      arrivalAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Arrival alarm (ID: 6) scheduled - will fire if arrival not confirmed');
  }

  /// Schedules all alarms for the next 7 days using the 7-day rolling window strategy.
  /// Only schedules alarms for days that match the activeDaysOfWeek pattern.
  /// Uses the alarm ID scheme: (dayOffset * 1000) + baseAlarmId
  static Future<void> scheduleAlarmsFor7Days(AppSettings settings) async {
    print('🗓️ ===== SCHEDULING 7-DAY ROLLING WINDOW =====');
    final now = DateTime.now();
    int totalScheduled = 0;

    for (int dayOffset = 0; dayOffset <= 6; dayOffset++) {
      // Calculate target date for this day
      final targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
      
      // Check if this date is active (weekday is in activeDaysOfWeek)
      if (!settings.isActiveOnDate(targetDate)) {
        print('⏭️  Day $dayOffset (${_formatDate(targetDate)}): SKIPPED (inactive day)');
        continue;
      }

      print('📅 Day $dayOffset (${_formatDate(targetDate)}): Scheduling alarms...');
      
      // Calculate alarm times for this specific date
      final wakeUpTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        settings.wakeUpTime.hour,
        settings.wakeUpTime.minute,
      );
      
      final leaveHomeTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        settings.leaveHomeTime.hour,
        settings.leaveHomeTime.minute,
      );
      
      final arrivalDeadline = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        settings.arrivalDeadline.hour,
        settings.arrivalDeadline.minute,
      );
      
      // Schedule all alarms for this day
      int dayScheduled = await _scheduleAllAlarmsForDate(
        dayOffset: dayOffset,
        wakeUpTime: wakeUpTime,
        leaveHomeTime: leaveHomeTime,
        arrivalDeadline: arrivalDeadline,
        minutesBeforeLeaving1: settings.minutesBeforeLeaving1,
        minutesBeforeLeaving2: settings.minutesBeforeLeaving2,
        minutesBeforeArrival: settings.minutesBeforeArrival,
      );
      
      totalScheduled += dayScheduled;
      print('   ✅ Day $dayOffset: Scheduled $dayScheduled alarms');
    }

    print('🎉 ===== 7-DAY WINDOW COMPLETE: $totalScheduled total alarms scheduled =====');
  }

  /// Helper function to schedule all alarms for a specific date with the given day offset
  static Future<int> _scheduleAllAlarmsForDate({
    required int dayOffset,
    required DateTime wakeUpTime,
    required DateTime leaveHomeTime,
    required DateTime arrivalDeadline,
    required int minutesBeforeLeaving1,
    required int minutesBeforeLeaving2,
    required int minutesBeforeArrival,
  }) async {
    final now = DateTime.now();
    int scheduledCount = 0;

    // 1. Schedule Wake-Up Alarm (base ID: 1)
    final wakeUpId = (dayOffset * 1000) + 1;
    if (wakeUpTime.isAfter(now.add(const Duration(seconds: 5)))) {
      await AndroidAlarmManager.oneShotAt(
        wakeUpTime,
        wakeUpId,
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      scheduledCount++;
      print('   ⏰ Wake-up (ID $wakeUpId): ${_formatTime(wakeUpTime)}');
    }

    // 2. Schedule Checkpoint Alarms (base IDs: 100-119)
    final cutoffTime = leaveHomeTime.subtract(const Duration(minutes: 5));
    DateTime nextCheckIn = wakeUpTime.add(const Duration(minutes: 10));
    int checkpointIndex = 0;

    while (nextCheckIn.isBefore(cutoffTime) && checkpointIndex < 20) {
      final checkpointId = (dayOffset * 1000) + 100 + checkpointIndex;
      
      if (nextCheckIn.isAfter(now.add(const Duration(seconds: 5)))) {
        await AndroidAlarmManager.oneShotAt(
          nextCheckIn,
          checkpointId,
          checkInAlarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
        scheduledCount++;
        print('   ⏰ Checkpoint #${checkpointIndex + 1} (ID $checkpointId): ${_formatTime(nextCheckIn)}');
      }
      
      nextCheckIn = nextCheckIn.add(const Duration(minutes: 10));
      checkpointIndex++;
    }

    // 3. Schedule Leave-Home-Soon Alarm (base ID: 3)
    final leaveHomeSoonTime = leaveHomeTime.subtract(Duration(minutes: minutesBeforeLeaving1));
    final leaveHomeSoonId = (dayOffset * 1000) + 3;
    if (leaveHomeSoonTime.isAfter(now.add(const Duration(seconds: 5)))) {
      await AndroidAlarmManager.oneShotAt(
        leaveHomeSoonTime,
        leaveHomeSoonId,
        leaveHomeSoonCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      scheduledCount++;
      print('   ⏰ Leave-soon (ID $leaveHomeSoonId): ${_formatTime(leaveHomeSoonTime)}');
    }

    // 4. Schedule Leave-Home Alarm (base ID: 4)
    final leaveHomeId = (dayOffset * 1000) + 4;
    if (leaveHomeTime.isAfter(now)) {
      await AndroidAlarmManager.oneShotAt(
        leaveHomeTime,
        leaveHomeId,
        leaveHomeCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      scheduledCount++;
      print('   ⏰ Leave-home (ID $leaveHomeId): ${_formatTime(leaveHomeTime)}');
    }

    // 5. Schedule Arrival-Check Alarm (base ID: 5)
    final arrivalCheckTime = arrivalDeadline.subtract(Duration(minutes: minutesBeforeArrival));
    final arrivalCheckId = (dayOffset * 1000) + 5;
    if (arrivalCheckTime.isAfter(now.add(const Duration(seconds: 30)))) {
      await AndroidAlarmManager.oneShotAt(
        arrivalCheckTime,
        arrivalCheckId,
        arrivalCheckCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      scheduledCount++;
      print('   ⏰ Arrival-check (ID $arrivalCheckId): ${_formatTime(arrivalCheckTime)}');
    }

    // 6. Schedule Arrival Alarm (base ID: 6)
    final arrivalId = (dayOffset * 1000) + 6;
    if (arrivalDeadline.isAfter(now.add(const Duration(minutes: 1)))) {
      await AndroidAlarmManager.oneShotAt(
        arrivalDeadline,
        arrivalId,
        arrivalAlarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      scheduledCount++;
      print('   ⏰ Arrival (ID $arrivalId): ${_formatTime(arrivalDeadline)}');
    }

    return scheduledCount;
  }

  /// Format date for logging
  static String _formatDate(DateTime date) {
    final weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday]} ${date.month}/${date.day}';
  }

  /// Format time for logging
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> cancelAll() async {
    print('🗑️  Cancelling all alarms (7-day window)...');
    
    // Cancel alarms for all 7 days (day offset 0-6)
    for (int dayOffset = 0; dayOffset <= 6; dayOffset++) {
      // Cancel wake-up alarm (ID: dayOffset * 1000 + 1)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 1);
      
      // Cancel all check-in alarms (IDs: dayOffset * 1000 + 100-119)
      for (int checkpointId = 100; checkpointId < 120; checkpointId++) {
        await AndroidAlarmManager.cancel((dayOffset * 1000) + checkpointId);
      }
      
      // Cancel leave-home-soon alarm (ID: dayOffset * 1000 + 3)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 3);
      
      // Cancel leave-home alarm (ID: dayOffset * 1000 + 4)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 4);
      
      // Cancel arrival-check alarm (ID: dayOffset * 1000 + 5)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 5);
      
      // Cancel arrival alarm (ID: dayOffset * 1000 + 6)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 6);
    }
    
    // Cancel test alarm
    await AndroidAlarmManager.cancel(999);
    
    print('✅ All alarms cancelled (7-day window cleared)');
  }
  
  static Future<void> cancelArrivalAlarm() async {
    await AndroidAlarmManager.cancel(6);
    print('✅ Arrival Alarm (ID: 6) cancelled');
  }
}
