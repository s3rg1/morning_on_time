import 'dart:convert';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dnd_checker/dnd_checker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:native_sound_player/native_sound_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'localization_helper.dart';
import '../models/app_settings.dart';

const Duration _notificationToTtsDelay = Duration(seconds: 5);

/// Plays a notification sound on the **music stream** using Android's native
/// MediaPlayer via our native_sound_player plugin. This ensures notification
/// sounds and TTS share the same volume slider, and works reliably in
/// background isolates (unlike the `audioplayers` package whose AssetSource
/// resolver fails in background engines created by android_alarm_manager_plus).
///
/// [assetPath] – Flutter asset path, e.g. 'assets/sounds/wake-up/morning-rooster.wav'
Future<void> _playNotificationSound(String assetPath) async {
  try {
    await NativeSoundPlayer.playAsset(assetPath);
    print('🔊 Playing notification sound on media stream: $assetPath');
  } catch (e) {
    print('⚠️ Failed to play notification sound: $e');
  }
}

// Pre-Arrival Check channels with escalating custom sounds
const AndroidNotificationChannel _preArrivalGentleChannel = AndroidNotificationChannel(
  'pre_arrival_gentle_v2',
  'Pre-Arrival Reminder',
  description: 'Gentle reminder to confirm arrival (1 minute left)',
  importance: Importance.max,
  playSound: false,
  enableVibration: true,
);

const AndroidNotificationChannel _preArrivalUrgentChannel = AndroidNotificationChannel(
  'pre_arrival_urgent_v2',
  'Pre-Arrival Urgent',
  description: 'Urgent reminder to confirm arrival (30 seconds left)',
  importance: Importance.max,
  playSound: false,
  enableVibration: true,
);

const AndroidNotificationChannel _preArrivalCriticalChannel = AndroidNotificationChannel(
  'pre_arrival_critical_v2',
  'Pre-Arrival Critical',
  description: 'Critical last-chance reminder to confirm arrival (10 seconds left)',
  importance: Importance.max,
  playSound: false,
  enableVibration: true,
);

const AndroidNotificationChannel _arrivalDeadlineSilentChannel = AndroidNotificationChannel(
  'arrival_deadline_silent_v2',
  'Arrival Deadline Alerts',
  description: 'Silent arrival deadline notifications',
  importance: Importance.max,
  playSound: false,
  enableVibration: true,
);

Future<void> _speakAfterStandardDelay({
  required String ttsLanguage,
  required String message,
  required String delayLog,
  required String completionLog,
}) async {
  print(delayLog);
  await Future.delayed(_notificationToTtsDelay);

  final FlutterTts tts = FlutterTts();
  await tts.setLanguage(ttsLanguage);
  await tts.setPitch(1.0);
  await tts.setVolume(1.0);
  await tts.setSpeechRate(0.5);
  await tts.speak(message);

  print(completionLog);
}

/// Persist the last journey notification message so the UI can display it.
Future<void> _saveLastJourneyNotification(String message) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_journey_notification', message);
  await prefs.setInt('last_journey_notification_time',
      DateTime.now().millisecondsSinceEpoch);
}

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
  final wakeUpMessages = await LocalizationHelper.getWakeUpMessages();
  final wakeUpMessage = wakeUpMessages[Random().nextInt(wakeUpMessages.length)];
  final wakeUpTitle = await LocalizationHelper.getWakeUpTitle();

  // Persist for journey card banner
  await _saveLastJourneyNotification('☀️ $wakeUpMessage');
  
  // Show notification with custom sound FIRST (per PRD: sound before TTS)
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notifications.initialize(initializationSettings);
  
  // CRITICAL: Create notification channel WITHOUT custom sound (Android 8.0+)
  // Sound is now played via audioplayers on the media stream for unified volume
  const AndroidNotificationChannel wakeUpChannel = AndroidNotificationChannel(
    'wake_up_alarm_v2',
    'Wake-Up Alarms',
    description: 'Wake-up notifications',
    importance: Importance.max,
    playSound: false,
    enableVibration: true,
  );
  
  // Create the channel (required for Android 8.0+)
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(wakeUpChannel);
  
  // Android: Reference the channel we just created
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'wake_up_alarm_v2',  // Must match channel ID above
    'Wake-Up Alarms',
    channelDescription: 'Wake-up notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  // iOS: Sound also played via audioplayers for consistency
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await notifications.show(
    1,
    wakeUpTitle,
    wakeUpMessage,
    notificationDetails,
  );
  
  print('✅ Wake-up notification shown (silent channel)');
  
  // Skip audio when Do Not Disturb is active (notification + vibration still fire)
  final dndActive = await DndChecker.isDndActive();
  if (dndActive) {
    print('🔇 DND active — skipping wake-up sound & TTS');
  } else {
    // Play notification sound on media stream (same stream as TTS)
    await _playNotificationSound('assets/sounds/wake-up/morning-rooster.wav');
    
    await _speakAfterStandardDelay(
      ttsLanguage: ttsLanguage,
      message: wakeUpMessage,
      delayLog: '⏳ Waiting 5 seconds before wake-up TTS...',
      completionLog: '✅ Wake-up TTS message spoken',
    );
  }
  
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

        final List<Map<String, dynamic>> day8ManifestEntries = [];
        
        // Schedule all alarms for day 8 with dayOffset = 7
        final scheduledCount = await AlarmService._scheduleAllAlarmsForDate(
          dayOffset: 7,
          wakeUpTime: day8WakeUp,
          leaveHomeTime: day8Leave,
          arrivalDeadline: day8Arrival,
          minutesBeforeLeaving1: settings.minutesBeforeLeaving1,
          minutesBeforeLeaving2: settings.minutesBeforeLeaving2,
          minutesBeforeArrival: settings.minutesBeforeArrival,
          manifestCollector: day8ManifestEntries,
        );

        await AlarmService._mergeManifestEntries(day8ManifestEntries);
        
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

// Checkpoint alarms fire every 5 minutes - these don't auto-reschedule
// They show notification with random custom sound, then play TTS
String _buildCheckpointMessage({
  required int minutesLeft,
  required int totalMinutes,
  required String ttsLanguage,
  required Random random,
  String? pendingRewardName,
}) {
  final double remainingRatio =
      totalMinutes > 0 ? minutesLeft / totalMinutes : 0.0;

  final templates = LocalizationHelper.getCheckpointTemplates(
    ttsLanguage: ttsLanguage,
    remainingRatio: remainingRatio,
  ).toList();

  if (pendingRewardName != null && pendingRewardName.isNotEmpty) {
    templates.add(
      LocalizationHelper.getCheckpointRewardTemplate(
        ttsLanguage: ttsLanguage,
        remainingRatio: remainingRatio,
      ),
    );
  }

  final selectedTemplate = templates[random.nextInt(templates.length)];
  return selectedTemplate
      .replaceAll('{minutes}', minutesLeft.toString())
      .replaceAll('{reward}', pendingRewardName ?? '');
}

String? _getPendingRewardName(SharedPreferences prefs) {
  try {
    final rewardsJson = prefs.getString('rewards');
    if (rewardsJson == null) return null;

    final rewards = jsonDecode(rewardsJson) as List<dynamic>;
    final currentStreak = prefs.getInt('current_streak') ?? 0;

    for (final rewardRaw in rewards) {
      if (rewardRaw is! Map<String, dynamic>) continue;

      final isActive = rewardRaw['isActive'] as bool? ?? true;
      if (!isActive) continue;

      final rewardName = rewardRaw['name'] as String?;
      if (rewardName == null || rewardName.trim().isEmpty) continue;

      final requiredStreak = (rewardRaw['requiredStreakLength'] as num?)?.toInt() ?? 0;
      if (currentStreak < requiredStreak) {
        return rewardName;
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

@pragma('vm:entry-point')
void checkInAlarmCallback() async {
  print('⏰ CHECKPOINT ALARM FIRED!');
  
  final now = DateTime.now();
  
  // Get leave home time from settings to calculate minutes remaining
  final prefs = await SharedPreferences.getInstance();
  final settingsJson = prefs.getString('app_settings');
  
  int minutesLeft = 0;
  int totalMinutes = 0;
  String? pendingRewardName;
  if (settingsJson != null) {
    try {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettings.fromJson(settingsMap);
      pendingRewardName = _getPendingRewardName(prefs);
      
      final wakeUpTime = DateTime(
        now.year,
        now.month,
        now.day,
        settings.wakeUpTime.hour,
        settings.wakeUpTime.minute,
      );
      
      var leaveTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        settings.leaveHomeTime.hour, 
        settings.leaveHomeTime.minute
      );

      if (!leaveTime.isAfter(wakeUpTime)) {
        leaveTime = leaveTime.add(const Duration(days: 1));
      }

      minutesLeft = leaveTime.difference(now).inMinutes;
      totalMinutes = leaveTime.difference(wakeUpTime).inMinutes;
      
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
  final checkInTitle = await LocalizationHelper.getCheckInTitle();
  
  // 🔔 Step 1: Show notification with sound played via audioplayers (media stream)
  // Randomly select one of the checkpoint sounds
  final random = Random();
  final checkpointSounds = [
    {'asset': 'assets/sounds/checkpoints/alarm-clock.wav', 'channel': 'checkpoint_silent_v2'},
    {'asset': 'assets/sounds/checkpoints/church-bell.wav', 'channel': 'checkpoint_silent_v2'},
  ];
  final selectedSound = checkpointSounds[random.nextInt(checkpointSounds.length)];
  final soundAsset = selectedSound['asset'] as String;
  final channelId = selectedSound['channel'] as String;
  
  print('🔔 Selected random checkpoint sound: $soundAsset');
  
  // Show notification with custom sound FIRST (per PRD: sound before TTS)
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notifications.initialize(initializationSettings);
  
  // CRITICAL: Create notification channel WITHOUT custom sound (Android 8.0+)
  // Sound is now played via audioplayers on the media stream for unified volume
  final checkpointChannel = AndroidNotificationChannel(
    channelId,  // Shared silent channel
    'Checkpoint Alarms',
    description: 'Checkpoint notifications',
    importance: Importance.max,
    playSound: false,
    enableVibration: true,
  );
  
  // Create the channel (required for Android 8.0+)
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(checkpointChannel);
  
  // Android: Reference the channel we just created
  final androidDetails = AndroidNotificationDetails(
    channelId,  // Must match channel ID above
    'Checkpoint Alarms',
    channelDescription: 'Checkpoint notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  // iOS: Use custom sound from bundle (if needed)
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  final notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  // Build notification message with minutes left
  final clampedMinutesLeft = max(1, minutesLeft);
  final selectedMessage = _buildCheckpointMessage(
    minutesLeft: clampedMinutesLeft,
    totalMinutes: totalMinutes,
    ttsLanguage: ttsLanguage,
    random: random,
    pendingRewardName: pendingRewardName,
  );
  final String notificationBody = selectedMessage;

  // Persist for journey card banner
  await _saveLastJourneyNotification('⏰ $notificationBody');
  
  // Show notification (silent — sound played separately below)
  await notifications.show(
    100 + random.nextInt(20),  // Random ID between 100-119 for checkpoint alarms
    checkInTitle,
    notificationBody,
    notificationDetails,
  );
  
  print('✅ Checkpoint notification shown (silent channel)');
  
  // Skip audio when Do Not Disturb is active
  final dndActive = await DndChecker.isDndActive();
  if (dndActive) {
    print('🔇 DND active — skipping checkpoint sound & TTS');
  } else {
    // Play notification sound on media stream (same stream as TTS)
    await _playNotificationSound(soundAsset);
    
    // 🔊 Step 2: Play TTS message after notification sound
    // Build dynamic TTS message with minutes left
    final String ttsMessage = selectedMessage;

    await _speakAfterStandardDelay(
      ttsLanguage: ttsLanguage,
      message: ttsMessage,
      delayLog: '⏳ Waiting 5 seconds before checkpoint TTS...',
      completionLog: '✅ Checkpoint TTS played: "$ttsMessage"',
    );
  }
  // Note: Checkpoint alarms don't auto-reschedule, they're scheduled fresh each day
}

@pragma('vm:entry-point')
void leaveHomeSoonCallback() async {
  print('🏃 LEAVE HOME SOON ALARM FIRED!');
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final leaveHomeSoonMessages = await LocalizationHelper.getLeaveHomeSoonMessages();
  final leaveHomeSoonMessage = leaveHomeSoonMessages[Random().nextInt(leaveHomeSoonMessages.length)];
  final leaveHomeSoonTitle = await LocalizationHelper.getLeaveHomeSoonTitle();

  // Persist for journey card banner
  await _saveLastJourneyNotification('🚨 $leaveHomeSoonMessage');
  
  // 🚨 Step 1: Show notification with sound played via audioplayers (media stream)
  // Randomly select one of the leave-soon sounds
  final random = Random();
  final leaveSoonSounds = [
    'assets/sounds/leave-soon/nuclear-alarm.wav',
    'assets/sounds/leave-soon/red-alert_nuclear_buzzer.mp3',
  ];
  final soundAsset = leaveSoonSounds[random.nextInt(leaveSoonSounds.length)];
  final channelId = 'leave_soon_silent_v2';
  
  print('🚨 Selected random leave-soon sound: $soundAsset');
  
  // Show notification with custom sound FIRST (per PRD: sound before TTS)
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notifications.initialize(initializationSettings);
  
  // CRITICAL: Create notification channel WITHOUT custom sound (Android 8.0+)
  // Sound is now played via audioplayers on the media stream for unified volume
  final leaveSoonChannel = AndroidNotificationChannel(
    channelId,  // Shared silent channel
    'Leave Home Soon Alarms',
    description: 'Leave home soon notifications',
    importance: Importance.max,
    playSound: false,
    enableVibration: true,
  );
  
  // Create the channel (required for Android 8.0+)
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(leaveSoonChannel);
  
  // Android: Reference the channel we just created
  final androidDetails = AndroidNotificationDetails(
    channelId,  // Must match channel ID above
    'Leave Home Soon Alarms',
    channelDescription: 'Leave home soon notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
  );
  
  // iOS: Use custom sound from bundle (if needed)
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  final notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  // Show notification (silent — sound played separately below)
  await notifications.show(
    3,
    leaveHomeSoonTitle,
    leaveHomeSoonMessage,
    notificationDetails,
  );
  
  print('✅ Leave home soon notification shown (silent channel)');
  
  // Skip audio when Do Not Disturb is active
  final dndActive = await DndChecker.isDndActive();
  if (dndActive) {
    print('🔇 DND active — skipping leave-soon sound & TTS');
  } else {
    // Play notification sound on media stream (same stream as TTS)
    await _playNotificationSound(soundAsset);
    
    // 🔊 Step 2: Play TTS message after notification sound
    await _speakAfterStandardDelay(
      ttsLanguage: ttsLanguage,
      message: leaveHomeSoonMessage,
      delayLog: '⏳ Waiting 5 seconds before leave-soon TTS...',
      completionLog: '✅ Leave home soon TTS played: "$leaveHomeSoonMessage"',
    );
  }
}

@pragma('vm:entry-point')
void leaveHomeCallback() async {
  print('🚪 LEAVE HOME ALARM FIRED!');
  
  // Get localized messages
  final ttsLanguage = await LocalizationHelper.getTtsLanguage();
  final leaveHomeNowMessages = await LocalizationHelper.getLeaveHomeNowMessages();
  final leaveHomeNowMessage = leaveHomeNowMessages[Random().nextInt(leaveHomeNowMessages.length)];
  final leaveHomeNowTitle = await LocalizationHelper.getLeaveHomeNowTitle();
  final countdownTimerText = await LocalizationHelper.getOpenAppToSeeCountdown();

  // Persist for journey card banner
  await _saveLastJourneyNotification('🚗 $leaveHomeNowMessage');
  
  // Show notification with custom sound FIRST (per PRD: war-horn sound before TTS)
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize the plugin in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notifications.initialize(initializationSettings);
  
  // CRITICAL: Create notification channel WITHOUT custom sound (Android 8.0+)
  // Sound is now played via audioplayers on the media stream for unified volume
  const AndroidNotificationChannel leaveHomeChannel = AndroidNotificationChannel(
    'leave_home_alarm_v2',
    'Leave Home Alarms',
    description: 'Leave home notifications',
    importance: Importance.max,
    playSound: false,
    enableVibration: true,
  );
  
  // Create the channel (required for Android 8.0+)
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(leaveHomeChannel);
  
  // Android: Reference the channel we just created
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'leave_home_alarm_v2',  // Must match channel ID above
    'Leave Home Alarms',
    channelDescription: 'Leave home notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
    ongoing: true, // Make it persistent during journey
    autoCancel: false,
  );
  
  // iOS: Sound also played via audioplayers for consistency
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await notifications.show(
    4,
    leaveHomeNowTitle,
    '$leaveHomeNowMessage $countdownTimerText',
    notificationDetails,
    payload: 'leave_home', // Add payload to identify this notification
  );
  
  print('✅ Leave home notification shown (silent channel)');
  
  // No need to set journey flag - countdown now computed purely from time!
  print('🚀 Leave home time reached - countdown will appear automatically');
  
  // Skip audio when Do Not Disturb is active
  final dndActive = await DndChecker.isDndActive();
  if (dndActive) {
    print('🔇 DND active — skipping leave-home sound & TTS');
  } else {
    // Play notification sound on media stream (same stream as TTS)
    await _playNotificationSound('assets/sounds/leave-now/war-horn.wav');
    
    await _speakAfterStandardDelay(
      ttsLanguage: ttsLanguage,
      message: leaveHomeNowMessage,
      delayLog: '⏳ Waiting 5 seconds before leave-home TTS...',
      completionLog: '✅ Leave-home TTS message spoken',
    );
  }
}

/// Shared callback for all 3 Pre-Arrival Check alarms (IDs: 5, 7, 8).
/// Determines urgency level from time remaining until arrival deadline,
/// then shows a notification with the appropriate escalating sound and text.
@pragma('vm:entry-point')
void preArrivalCheckCallback() async {
  print('🎯 PRE-ARRIVAL CHECK ALARM FIRED!');

  // Skip if arrival already confirmed
  final prefs = await SharedPreferences.getInstance();
  final arrivalConfirmed = prefs.getBool('arrival_confirmed') ?? false;
  if (arrivalConfirmed) {
    print('✅ Arrival already confirmed - skipping pre-arrival notification');
    return;
  }

  // Determine arrival deadline from settings or test deadline
  DateTime? arrivalDeadline;
  final testDeadlineStr = prefs.getString('test_arrival_deadline');
  if (testDeadlineStr != null) {
    arrivalDeadline = DateTime.tryParse(testDeadlineStr);
  }
  if (arrivalDeadline == null) {
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        final settings = AppSettings.fromJson(settingsMap);
        final now = DateTime.now();
        arrivalDeadline = DateTime(
          now.year, now.month, now.day,
          settings.arrivalDeadline.hour,
          settings.arrivalDeadline.minute,
        );
      } catch (e) {
        print('⚠️ Error reading settings for arrival deadline: $e');
      }
    }
  }

  // Calculate seconds remaining to pick urgency level
  final secondsRemaining = arrivalDeadline != null
      ? arrivalDeadline.difference(DateTime.now()).inSeconds
      : 60; // fallback if we can't determine

  // Pick channel, notification ID, title and body based on remaining time
  final AndroidNotificationChannel channel;
  final int notificationId;
  final String soundAsset;

  final String title;
  final String body;
  final arrivedYesText = await LocalizationHelper.getArrivedYesText();

  if (secondsRemaining > 45) {
    // T-60s alarm (gentle)
    channel = _preArrivalGentleChannel;
    notificationId = 5;
    soundAsset = 'assets/sounds/pre-arrival/pre_arrival_gentle.wav';
    title = await LocalizationHelper.getPreArrivalTitle1();
    body = await LocalizationHelper.getPreArrivalBody1();
  } else if (secondsRemaining > 15) {
    // T-30s alarm (urgent)
    channel = _preArrivalUrgentChannel;
    notificationId = 7;
    soundAsset = 'assets/sounds/pre-arrival/pre_arrival_urgent.wav';
    title = await LocalizationHelper.getPreArrivalTitle2();
    body = await LocalizationHelper.getPreArrivalBody2();
  } else {
    // T-10s alarm (critical)
    channel = _preArrivalCriticalChannel;
    notificationId = 8;
    soundAsset = 'assets/sounds/pre-arrival/pre_arrival_critical.wav';
    title = await LocalizationHelper.getPreArrivalTitle3();
    body = await LocalizationHelper.getPreArrivalBody3();
  }

  print('🔔 Pre-arrival urgency: ${secondsRemaining}s remaining → notification ID $notificationId');

  // Persist for journey card banner
  await _saveLastJourneyNotification(
    notificationId == 8 ? '🚨 $body' : notificationId == 7 ? '⚠️ $body' : '🎯 $body',
  );

  // Initialize notifications in background isolate
  final notifications = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);

  // Create the appropriate channel
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
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

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await notifications.show(
    notificationId,
    title,
    body,
    notificationDetails,
  );

  // Skip audio when Do Not Disturb is active
  final dndActive = await DndChecker.isDndActive();
  if (dndActive) {
    print('🔇 DND active — skipping pre-arrival sound');
  } else {
    // Play notification sound on media stream (same stream as TTS)
    await _playNotificationSound(soundAsset);
  }

  print('✅ Pre-arrival check notification shown (ID: $notificationId)');
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

  // Extra guard: if today's record is already a success, never override it
  final alreadyOnTime = await AlarmService.hasOnTimeRecordForToday();
  if (alreadyOnTime) {
    print('✅ Today already marked on-time - skipping failure path');
    return;
  }
  
  print('❌ Arrival NOT confirmed - marking day as missed');
  
  // Get localized notification copy
  final locale = await LocalizationHelper.getLocale();
  final String title;
  final String body;
  
  if (locale == 'es') {
    title = '⌛ ¡Se acabó el tiempo!';
    body = 'No llegamos a tiempo hoy';
  } else {
    title = '⌛ Time is up!';
    body = 'We did not arrive on time today';
  }
  
  // Show notification
  final notifications = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await notifications.initialize(initializationSettings);

  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_arrivalDeadlineSilentChannel);
  
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    _arrivalDeadlineSilentChannel.id,
    _arrivalDeadlineSilentChannel.name,
    channelDescription: _arrivalDeadlineSilentChannel.description,
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
  );
  
  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await notifications.show(
    6,
    title,
    body,
    notificationDetails,
  );
  
  // Mark mission as failed using shared helper
  await AlarmService.markMissionFailed();
  
  // Do NOT reschedule here - this alarm is scheduled by the 7-day rolling window planner.
}

class AlarmService {
  static const String _plannedAlarmsManifestKey = 'planned_alarms_manifest';
  static const String _plannedAlarmsManifestUpdatedAtKey = 'planned_alarms_manifest_updated_at';

  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    print('✅ AlarmManager initialized');
  }

  static Map<String, dynamic> _createManifestEntry({
    required int id,
    required String name,
    required String type,
    required DateTime date,
  }) {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  static Future<void> _savePlannedManifest(List<Map<String, dynamic>> manifest) async {
    final prefs = await SharedPreferences.getInstance();
    manifest.sort((a, b) {
      final aDate = DateTime.parse(a['date'] as String);
      final bDate = DateTime.parse(b['date'] as String);
      return aDate.compareTo(bDate);
    });
    await prefs.setString(_plannedAlarmsManifestKey, jsonEncode(manifest));
    await prefs.setString(
      _plannedAlarmsManifestUpdatedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> _mergeManifestEntries(List<Map<String, dynamic>> newEntries) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_plannedAlarmsManifestKey);

    List<Map<String, dynamic>> manifest = [];
    if (existingJson != null) {
      try {
        final decoded = jsonDecode(existingJson) as List<dynamic>;
        manifest = decoded
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (_) {
        manifest = [];
      }
    }

    final now = DateTime.now().subtract(const Duration(minutes: 1));
    manifest = manifest.where((entry) {
      final dateString = entry['date'] as String?;
      if (dateString == null) return false;
      try {
        return DateTime.parse(dateString).isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();

    for (final newEntry in newEntries) {
      final newId = newEntry['id'];
      final newDate = newEntry['date'];
      manifest.removeWhere((entry) => entry['id'] == newId && entry['date'] == newDate);
      manifest.add(newEntry);
    }

    await _savePlannedManifest(manifest);
  }
  
  /// Shared helper: Mark mission as failed
  /// Used by both arrivalAlarmCallback and confirmArrival(false)
  static Future<bool> hasOnTimeRecordForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final recordsJson = prefs.getString('day_records');
    if (recordsJson == null) return false;

    try {
      final recordsList = json.decode(recordsJson) as List<dynamic>;
      final existingIndex = recordsList.indexWhere((r) {
        try {
          final recordDate = DateTime.parse(r['date']);
          final rDate = DateTime(recordDate.year, recordDate.month, recordDate.day);
          return rDate.isAtSameMomentAs(todayDate);
        } catch (e) {
          return false;
        }
      });

      if (existingIndex < 0) return false;

      final existingRecord = recordsList[existingIndex] as Map<String, dynamic>;
      return existingRecord['wasOnTime'] == true;
    } catch (e) {
      print('⚠️ Error checking today record: $e');
      return false;
    }
  }

  static Future<void> markMissionFailed({bool skipAnalytics = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Load existing records
    final recordsJson = prefs.getString('day_records');
    List<dynamic> recordsList = [];
    if (recordsJson != null) {
      try {
        recordsList = json.decode(recordsJson);
      } catch (e) {
        print('⚠️ Error loading records: $e');
      }
    }
    
    // Check if we already have a record for today
    final existingIndex = recordsList.indexWhere((r) {
      try {
        final recordDate = DateTime.parse(r['date']);
        final rDate = DateTime(recordDate.year, recordDate.month, recordDate.day);
        return rDate.isAtSameMomentAs(todayDate);
      } catch (e) {
        return false;
      }
    });

    // Create new record for failure
    final newRecord = {
      'date': todayDate.toIso8601String(),
      'wasOnTime': false,
      'arrivalTime': DateTime.now().toIso8601String(),
    };
    
    if (existingIndex >= 0) {
      recordsList[existingIndex] = newRecord;
    } else {
      recordsList.add(newRecord);
    }
    
    // Save records back
    await prefs.setString('day_records', json.encode(recordsList));
    
    // Queue deferred analytics events only from background isolate;
    // foreground callers log events directly and pass skipAnalytics: true.
    final previousStreak = prefs.getInt('current_streak') ?? 0;
    if (!skipAnalytics) {
      await AnalyticsService.queueDeferredEvent(
        name: 'journey_completed',
        parameters: {'on_time': 'false'},
      );
      if (previousStreak > 0) {
        await AnalyticsService.queueDeferredEvent(
          name: 'streak_broken',
          parameters: {'streak_length_before_reset': previousStreak},
        );
      }
    }

    // Reset streak
    await prefs.setInt('current_streak', 0);
    
    print('✅ Mission marked as failed: DayRecord created, streak reset');
  }
  
  /// Schedules all alarms for the next 7 days using the 7-day rolling window strategy.
  /// Only schedules alarms for days that match the activeDaysOfWeek pattern.
  /// Uses the alarm ID scheme: (dayOffset * 1000) + baseAlarmId
  static Future<void> scheduleAlarmsFor7Days(AppSettings settings) async {
    print('🗓️ ===== SCHEDULING 7-DAY ROLLING WINDOW =====');
    final now = DateTime.now();
    int totalScheduled = 0;
    final List<Map<String, dynamic>> manifest = [];

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
        manifestCollector: manifest,
      );
      
      totalScheduled += dayScheduled;
      print('   ✅ Day $dayOffset: Scheduled $dayScheduled alarms');
    }

    print('🎉 ===== 7-DAY WINDOW COMPLETE: $totalScheduled total alarms scheduled =====');
    await _savePlannedManifest(manifest);
    print('📋 Planned alarms manifest updated (${manifest.length} entries)');
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
    List<Map<String, dynamic>>? manifestCollector,
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
      manifestCollector?.add(_createManifestEntry(
        id: wakeUpId,
        name: '🌅 Wake-up',
        type: 'wake-up',
        date: wakeUpTime,
      ));
    }

    // 2. Schedule Checkpoint Alarms (base IDs: 100-119)
    final cutoffTime = leaveHomeTime.subtract(const Duration(minutes: 5));
    DateTime nextCheckIn = wakeUpTime.add(const Duration(minutes: 5));
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
        manifestCollector?.add(_createManifestEntry(
          id: checkpointId,
          name: '⏰ Checkpoint #${checkpointIndex + 1}',
          type: 'checkpoint',
          date: nextCheckIn,
        ));
      }
      
      nextCheckIn = nextCheckIn.add(const Duration(minutes: 5));
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
      manifestCollector?.add(_createManifestEntry(
        id: leaveHomeSoonId,
        name: '🏃 Leave-soon',
        type: 'leave-soon',
        date: leaveHomeSoonTime,
      ));
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
      manifestCollector?.add(_createManifestEntry(
        id: leaveHomeId,
        name: '🚪 Leave-home',
        type: 'leave-home',
        date: leaveHomeTime,
      ));
    }

    // 5. Schedule Pre-Arrival Check Alarms (base IDs: 5, 7, 8)
    // Three alarms at T-60s, T-30s, T-10s before arrival deadline
    final preArrivalOffsets = [
      {'baseId': 5, 'seconds': 60, 'name': '🎯 Pre-arrival (T-60s)'},
      {'baseId': 7, 'seconds': 30, 'name': '🎯 Pre-arrival (T-30s)'},
      {'baseId': 8, 'seconds': 10, 'name': '⚠️ Pre-arrival (T-10s)'},
    ];

    for (final offset in preArrivalOffsets) {
      final preArrivalTime = arrivalDeadline.subtract(
        Duration(seconds: offset['seconds'] as int),
      );
      final preArrivalId = (dayOffset * 1000) + (offset['baseId'] as int);
      if (preArrivalTime.isAfter(now.add(const Duration(seconds: 5)))) {
        await AndroidAlarmManager.oneShotAt(
          preArrivalTime,
          preArrivalId,
          preArrivalCheckCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
        scheduledCount++;
        print('   ⏰ ${offset['name']} (ID $preArrivalId): ${_formatTime(preArrivalTime)}');
        manifestCollector?.add(_createManifestEntry(
          id: preArrivalId,
          name: offset['name'] as String,
          type: 'pre-arrival-check',
          date: preArrivalTime,
        ));
      }
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
      manifestCollector?.add(_createManifestEntry(
        id: arrivalId,
        name: '⌛ Arrival',
        type: 'arrival',
        date: arrivalDeadline,
      ));
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
      
      // Cancel pre-arrival-check alarms (IDs: dayOffset * 1000 + 5, 7, 8)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 5);
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 7);
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 8);
      
      // Cancel arrival alarm (ID: dayOffset * 1000 + 6)
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 6);
    }
    
    // Cancel test alarm
    await AndroidAlarmManager.cancel(999);
    
    print('✅ All alarms cancelled (7-day window cleared)');
  }
  
  static Future<void> cancelArrivalAlarm() async {
    // Cancel all pre-arrival check + arrival alarms across the full rolling window
    for (int dayOffset = 0; dayOffset <= 7; dayOffset++) {
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 5);
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 7);
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 8);
      await AndroidAlarmManager.cancel((dayOffset * 1000) + 6);
    }

    // Dismiss already-shown arrival notifications if present
    final notifications = FlutterLocalNotificationsPlugin();
    await notifications.cancel(5);
    await notifications.cancel(7);
    await notifications.cancel(8);
    await notifications.cancel(6);

    print('✅ Arrival-related alarms cancelled (IDs: *005, *007, *008, *006)');
  }
}
