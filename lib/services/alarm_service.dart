import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_helper.dart';

// Top-level callback function - must be static or top-level
@pragma('vm:entry-point')
void alarmCallback() async {
  print('🚨 WAKE-UP ALARM FIRED!');
  
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
  
  // Reschedule wake-up for tomorrow at the same time
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
    1,
    alarmCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
  
  print('✅ Wake-up alarm rescheduled for tomorrow: $tomorrow');
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
  
  // Safety check: Don't play if it's outside reasonable hours
  final now = DateTime.now();
  final hour = now.hour;
  
  // Only play between 5 AM and 3 PM
  if (hour < 5 || hour >= 15) {
    print('⚠️ Skipping checkpoint - outside reasonable hours (current hour: $hour)');
    return;
  }
  
  // Get leave home time from settings to calculate minutes remaining
  final prefs = await SharedPreferences.getInstance();
  final settingsJson = prefs.getString('app_settings');
  
  int minutesLeft = 0;
  if (settingsJson != null) {
    try {
      final settings = Map<String, dynamic>.from(json.decode(settingsJson));
      final leaveTimeData = settings['leaveHomeTime'] as Map<String, dynamic>;
      final leaveHour = leaveTimeData['hour'] as int;
      final leaveMinute = leaveTimeData['minute'] as int;
      
      final leaveTime = DateTime(now.year, now.month, now.day, leaveHour, leaveMinute);
      minutesLeft = leaveTime.difference(now).inMinutes;
      
      // If already past leave time, don't play
      if (minutesLeft <= 0) {
        print('⚠️ Skipping checkpoint - already past leave time');
        return;
      }
    } catch (e) {
      print('Could not parse leave time from settings: $e');
      return;
    }
  } else {
    print('No settings found, skipping checkpoint');
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
  
  // START THE JOURNEY COUNTDOWN - Set flag in SharedPreferences
  print('🚀 Starting journey countdown...');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('journey_active', true);
  await prefs.setString('journey_start_time', DateTime.now().toIso8601String());
  
  // Verify the flag was set
  final verifyActive = prefs.getBool('journey_active');
  final verifyTime = prefs.getString('journey_start_time');
  print('✅ Journey flags set - active: $verifyActive, start_time: $verifyTime');
  
  // Calculate time until arrival deadline
  final settingsJson = prefs.getString('app_settings');
  int minutesToArrival = 30; // default
  if (settingsJson != null) {
    try {
      final settingsMap = Map<String, dynamic>.from(
        (const {}).cast<String, dynamic>()..addAll(
          Map<String, dynamic>.from(
            (const {}).cast<String, dynamic>()..addAll(
              Map<String, dynamic>.from({})
            )
          )
        )
      );
      // We'll just use a reasonable estimate since parsing is complex in background
      // The app will show the accurate countdown when opened
    } catch (e) {
      print('Could not parse settings, using default');
    }
  }
  
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
  
  static Future<void> cancelAll() async {
    // Cancel wake-up alarm
    await AndroidAlarmManager.cancel(1);
    
    // Cancel all check-in alarms (IDs 100-119)
    for (int id = 100; id < 120; id++) {
      await AndroidAlarmManager.cancel(id);
    }
    
    // Cancel leave-home-soon alarm
    await AndroidAlarmManager.cancel(3);
    
    // Cancel leave-home alarm
    await AndroidAlarmManager.cancel(4);
    
    // Cancel arrival-check alarm
    await AndroidAlarmManager.cancel(5);
    
    // Cancel arrival alarm
    await AndroidAlarmManager.cancel(6);
    
    // Cancel test alarm
    await AndroidAlarmManager.cancel(999);
    
    print('✅ All alarms cancelled');
  }
  
  static Future<void> cancelArrivalAlarm() async {
    await AndroidAlarmManager.cancel(6);
    print('✅ Arrival Alarm (ID: 6) cancelled');
  }
}
