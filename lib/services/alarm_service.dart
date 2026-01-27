import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'localization_helper.dart';

// Top-level callback function - must be static or top-level
@pragma('vm:entry-point')
void alarmCallback() async {
  print('🚨 ALARM FIRED! Time to wake up!');
  
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
  
  print('✅ Notification shown from alarm callback');
  
  // Reschedule for tomorrow at the same time
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
  
  print('✅ Rescheduled for tomorrow: $tomorrow');
}

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

// Check-in alarms fire every 8 minutes - these don't auto-reschedule
@pragma('vm:entry-point')
void checkInAlarmCallback() async {
  print('⏰ CHECK-IN ALARM FIRED!');
  
  // Safety check: Don't show notification if it's outside reasonable hours
  // (This prevents stale alarms from firing at wrong times)
  final now = DateTime.now();
  final hour = now.hour;
  
  // Only show check-in notifications between 5 AM and 3 PM
  if (hour < 5 || hour >= 15) {
    print('⚠️ Skipping check-in notification - outside reasonable hours (current hour: $hour)');
    return;
  }
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final checkInMessage = await LocalizationHelper.getCheckInMessage();
  final checkInTitle = await LocalizationHelper.getCheckInTitle();
  final goingWellText = await LocalizationHelper.getGoingWellText();
  final runningTightText = await LocalizationHelper.getRunningTightText();
  
  // Initialize TTS for voice message
  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  
  // Speak the check-in message
  await tts.speak(checkInMessage);
  
  // Show notification with action buttons
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
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
        'going_well',
        goingWellText,
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        'running_tight',
        runningTightText,
        showsUserInterface: false,
      ),
    ],
  );
  
  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  
  await notifications.show(
    2,
    checkInTitle,
    checkInMessage,
    notificationDetails,
  );
  
  print('✅ Check-in notification shown from alarm callback');
  // Note: Check-in alarms don't auto-reschedule, they're scheduled fresh each day
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
    4,
    leaveHomeNowTitle,
    leaveHomeNowMessage,
    notificationDetails,
  );
  
  print('✅ Leave home notification shown');
  
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
  final arrivedNoText = await LocalizationHelper.getArrivedNoText();
  
  // Show notification with action buttons
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
      AndroidNotificationAction(
        'arrived_no',
        arrivedNoText,
        showsUserInterface: false,
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
  
  // Schedule multiple check-in alarms every 8 minutes
  // from wake-up time until 6 minutes before leave time
  static Future<void> scheduleCheckInAlarms(
    DateTime wakeUpTime,
    DateTime leaveHomeTime,
  ) async {
    final now = DateTime.now();
    
    // Calculate the cutoff time (6 minutes before leave)
    final cutoffTime = leaveHomeTime.subtract(const Duration(minutes: 6));
    
    // Start scheduling check-ins 8 minutes after wake-up
    DateTime nextCheckIn = wakeUpTime.add(const Duration(minutes: 8));
    
    int alarmId = 100; // Start check-in IDs at 100
    int scheduledCount = 0;
    
    while (nextCheckIn.isBefore(cutoffTime)) {
      // Skip alarms in the past OR too close to now (within 2 minutes)
      // to prevent immediate triggering
      final timeUntilAlarm = nextCheckIn.difference(now);
      if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 2) {
        print('⏰ Skipping check-in alarm (time already passed or too soon): $nextCheckIn');
        nextCheckIn = nextCheckIn.add(const Duration(minutes: 8));
        alarmId++;
        continue;
      }
      
      print('⏰ Scheduling check-in alarm #${scheduledCount + 1} for: $nextCheckIn (in ${timeUntilAlarm.inMinutes} minutes)');
      
      await AndroidAlarmManager.oneShotAt(
        nextCheckIn,
        alarmId,
        checkInAlarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      scheduledCount++;
      
      // Move to next check-in (8 minutes later)
      nextCheckIn = nextCheckIn.add(const Duration(minutes: 8));
      alarmId++;
      
      // Safety limit: max 20 check-in alarms per day
      if (alarmId >= 120) break;
    }
    
    if (scheduledCount == 0) {
      print('✅ No check-in alarms scheduled (all times have passed or too soon for today)');
    } else {
      print('✅ Scheduled $scheduledCount check-in alarm(s)');
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
    
    // Skip if in the past or too close to now (within 2 minutes)
    final timeUntilAlarm = leaveHomeTime.difference(now);
    if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 2) {
      print('⏰ Skipping leave-home alarm (time already passed or too soon): $leaveHomeTime');
      return;
    }
    
    print('⏰ Scheduling leave-home alarm for: $leaveHomeTime (in ${timeUntilAlarm.inMinutes} minutes)');
    
    await AndroidAlarmManager.oneShotAt(
      leaveHomeTime,
      4, // Unique ID for leave-home alarm
      leaveHomeCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Leave-home alarm scheduled');
  }
  
  static Future<void> scheduleArrivalCheckAlarm(DateTime arrivalTime) async {
    final now = DateTime.now();
    
    // 2 minutes before arrival time
    final alarmTime = arrivalTime.subtract(const Duration(minutes: 2));
    
    // Skip if in the past or too close to now (within 2 minutes)
    final timeUntilAlarm = alarmTime.difference(now);
    if (timeUntilAlarm.isNegative || timeUntilAlarm.inMinutes < 2) {
      print('⏰ Skipping arrival-check alarm (time already passed or too soon): $alarmTime');
      return;
    }
    
    print('⏰ Scheduling arrival-check alarm for: $alarmTime (in ${timeUntilAlarm.inMinutes} minutes)');
    
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      5, // Unique ID for arrival-check alarm
      arrivalCheckCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('✅ Arrival-check alarm scheduled');
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
    
    // Cancel test alarm
    await AndroidAlarmManager.cancel(999);
    
    print('✅ All alarms cancelled');
  }
}
