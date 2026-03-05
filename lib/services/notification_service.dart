import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_settings.dart';
import '../models/check_in_status.dart';
import 'voice_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  static final VoiceService _voice = VoiceService();
  
  static void Function(CheckInStatus)? onCheckInResponse;
  static void Function(bool)? onArrivalConfirmation;
  
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'morning_on_time_channel',
    'Morning Notifications',
    description: 'Notifications for Morning Mission app',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Get the local timezone and set it
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if there's an error
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Create notification channel for Android
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static void _onNotificationTap(NotificationResponse response) async {
    // Handle notification taps and action buttons
    if (response.id == 1) {
      // Wake-up notification tapped - play voice message
      await _voice.playWakeUpMessage();
    } else if (response.id == 2) {
      // Check-in notification - handle action buttons
      if (response.actionId == 'going_well') {
        onCheckInResponse?.call(CheckInStatus.goingWell);
      }
      // Note: 'running_tight' removed - no longer supported
    } else if (response.id == 4) {
      // Leave home notification tapped - journey should be active
      // The app will automatically check and restore journey state via didChangeAppLifecycleState
      print('🚪 Leave home notification tapped - app will check journey state');
    } else if (response.id == 5 || response.id == 7 || response.id == 8) {
      // Pre-Arrival Check notifications (IDs 5, 7, 8) - same action button
      if (response.actionId == 'arrived_yes') {
        onArrivalConfirmation?.call(true); // Arrived on time
      }
      // Note: 'arrived_no' removed per PRD
    }
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Request notification permission
      await androidImplementation.requestNotificationsPermission();
      
      // Request exact alarm permission - this will open Android settings
      final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
      
      if (exactAlarmGranted == false) {
        print('⚠️ Exact alarms permission not granted. Notifications may not be precise.');
      }
      
      // Request to ignore battery optimization
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!batteryStatus.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
        
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Wake-up notification is now handled by AlarmService
  // This method has been removed to prevent duplicate notifications

  // Check-in notifications are now handled by AlarmService
  // This method has been removed to prevent duplicate notifications

  Future<void> showTimeToLeaveNotification(int minutes, CheckInStatus status) async {
    // Format the countdown time
    String timeText;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      timeText = mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else {
      timeText = '${minutes}m';
    }
    
    String title;
    String message;
    
    // Simplified: all countdown messages use same urgency based on time remaining
    if (minutes <= 2) {
      title = "🎯 Almost There!";
      message = "Only $timeText left - you've got this!";
    } else if (minutes <= 5) {
      title = "⏱️ Final Stretch!";
      message = "$timeText to arrival - stay focused!";
    } else {
      title = "✅ On Track!";
      message = "$timeText remaining - doing great!";
    }

    await _notifications.show(
      3,
      title,
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          usesChronometer: true,
          chronometerCountDown: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showArrivalPrompt() async {
    await _notifications.show(
      4,
      '🎯 Have we arrived?',
      'Tap to confirm arrival at school',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.max,
          actions: const [
            AndroidNotificationAction('arrived', 'Arrived!'),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('📋 Pending notifications: ${pending.length}');
    for (var notification in pending) {
      print('   - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    if (pending.isEmpty) {
      print('   ⚠️ No notifications are scheduled!');
    }
  }

  Future<void> listAllScheduledNotifications(AppSettings? settings) async {
    print('\n═══════════════════════════════════════════════════════════');
    print('📋 SCHEDULED NOTIFICATIONS OVERVIEW');
    print('═══════════════════════════════════════════════════════════\n');
    
    final now = DateTime.now();
    
    if (settings != null) {
      String formatTime(TimeOfDay time) {
        final hour = time.hour.toString().padLeft(2, '0');
        final minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }
      
      print('⚙️  Current Settings:');
      print('   Wake-up time: ${formatTime(settings.wakeUpTime)}');
      print('   Leave home time: ${formatTime(settings.leaveHomeTime)}');
      print('   Arrival deadline: ${formatTime(settings.arrivalDeadline)}');
      print('   Minutes before leaving (first warning): ${settings.minutesBeforeLeaving1}');
      print('   Minutes before leaving (second warning): ${settings.minutesBeforeLeaving2}');
      print('   Minutes before arrival: ${settings.minutesBeforeArrival}\n');
      
      print('📅 Expected Notification Times:');
      print('   ─────────────────────────────────────────────────────────');
      print('   ℹ️  NOTE: Alarms are managed by AlarmService.scheduleAlarmsFor7Days()');
      print('   ℹ️  This service reports expected timings from current settings\n');
      
      print('   1️⃣  Wake-up alarm (AlarmService):');
      print('      📍 Managed by: AlarmService.scheduleAlarmsFor7Days()');
      print('      ⏱️  Fires at: ${formatTime(settings.wakeUpTime)}');
      print('      📢 Message: "🌅 Good Morning! Today\'s mission is to arrive at school on time."');
      print('      ℹ️  Scheduled in 7-day rolling window\n');
      
      print('   2️⃣  Check-in alarms (AlarmService):');
      print('      📍 Managed by: AlarmService.scheduleAlarmsFor7Days()');
      print('      ⏱️  Fires: Every 5 minutes from wake-up until 5 min before leave time');
      print('      📢 Message: "⏰ Quick Check-In - How are things going?"');
      print('      ℹ️  Multiple alarms scheduled throughout morning\n');
      
      print('   3️⃣  Leave Home Soon alarm (AlarmService):');
      print('      📍 Managed by: AlarmService.scheduleAlarmsFor7Days()');
      print('      ⏱️  Fires: 5 minutes before ${formatTime(settings.leaveHomeTime)}');
      print('      📢 Message: "🏃 Leave Home Soon!"');
      print('      ℹ️  Scheduled in 7-day rolling window\n');
      
      print('   4️⃣  Leave Home Now alarm (AlarmService):');
      print('      📍 Managed by: AlarmService.scheduleAlarmsFor7Days()');
      print('      ⏱️  Fires at: ${formatTime(settings.leaveHomeTime)}');
      print('      📢 Message: "🚪 Leave Home Now!" + starts countdown timer');
      print('      ℹ️  Sets journey_active flag in SharedPreferences');
      print('      ℹ️  When app opens, countdown timer appears automatically\n');
      
      print('   5️⃣  Countdown Timer (Auto-starts):');
      print('      📍 Triggered by: Leave Home alarm setting journey_active flag');
      print('      📢 Display: Visual countdown on home screen');
      print('      ℹ️  Shows: Remaining time until arrival deadline');
      print('      ℹ️  Colors change based on urgency (green → amber → orange → red)\n');
      
      print('   6️⃣  Arrival check alarm (AlarmService):');
      print('      📍 Managed by: AlarmService.scheduleAlarmsFor7Days()');
      print('      ⏱️  Fires: 2 minutes before ${formatTime(settings.arrivalDeadline)}');
      print('      📢 Message: "🎯 Have we arrived on time?"');
      print('      ℹ️  Scheduled in 7-day rolling window\n');
    } else {
      print('⚠️  No settings configured yet. Run setup first.\n');
    }
    
    // Get actual pending notifications from the system
    final pending = await _notifications.pendingNotificationRequests();
    
    print('═══════════════════════════════════════════════════════════');
    print('📱 SYSTEM-SCHEDULED NOTIFICATIONS');
    print('═══════════════════════════════════════════════════════════\n');
    
    if (pending.isEmpty) {
      print('⚠️  No notifications currently in system queue!');
      print('   This might mean:');
      print('   • Notifications were cancelled');
      print('   • Battery optimization is blocking scheduling');
      print('   • App lacks notification permissions\n');
    } else {
      print('✅ Found ${pending.length} notification(s) in system queue:\n');
      for (var notification in pending) {
        String notifType = 'Unknown';
        if (notification.id == 1) notifType = 'Wake-up notification';
        else if (notification.id == 2) notifType = 'Check-in notification';
        else if (notification.id == 3) notifType = 'Time-to-leave update';
        else if (notification.id == 4) notifType = 'Arrival prompt';
        else if (notification.id == 5) notifType = 'Arrival confirmation';
        else if (notification.id == 998 || notification.id == 999) notifType = 'Test notification';
        
        print('   📌 $notifType (ID: ${notification.id})');
        print('      Title: ${notification.title}');
        print('      Body: ${notification.body}');
        print('');
      }
    }
    
    // Check exact alarm permission status
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final canScheduleExact = await androidImplementation.canScheduleExactNotifications() ?? false;
      print('═══════════════════════════════════════════════════════════');
      print('🔐 PERMISSIONS STATUS');
      print('═══════════════════════════════════════════════════════════\n');
      print('   Exact alarms: ${canScheduleExact ? "✅ Granted" : "❌ Not granted"}');
      if (!canScheduleExact) {
        print('   ⚠️  Without exact alarms, notifications may be delayed!');
      }
      print('');
    }
    
    print('═══════════════════════════════════════════════════════════\n');
  }

  Future<void> scheduleSimpleTest() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(minutes: 1));
    
    print('⏰ Current time: $now');
    print('📅 Scheduling simple test for: $scheduledTime (in 1 minute)');
    
    // Check battery optimization status
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        // Request to ignore battery optimizations
        print('🔋 Checking battery optimization...');
        final plugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        // Note: We need to manually check/request battery optimization exemption
      } catch (e) {
        print('⚠️ Battery optimization check failed: $e');
      }
    }
    
    try {
      await _notifications.zonedSchedule(
        999, // Different ID for test
        '🧪 Simple Test',
        'This should appear in 1 minute!',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Simple test scheduled successfully!');
      print('⚠️ IMPORTANT: Scheduled notifications may not work due to:');
      print('   1. Battery optimization blocking the app');
      print('   2. Android Doze mode preventing wake-ups');
      print('   3. App standby buckets restricting background work');
      print('💡 Try: Settings > Apps > Morning Mission > Battery > Unrestricted');
      
      // Check what's pending
      await getPendingNotifications();
    } catch (e) {
      print('❌ Failed to schedule simple test: $e');
    }
  }

  Future<void> scheduleAllNotifications(AppSettings settings) async {
    // Cancel all previous notifications
    await cancelAll();
    
    // Note: Wake-up and check-in notifications are now handled by AlarmService
    // This method only cancels old notifications to prevent duplicates
    // showTimeToLeaveNotification and showArrivalPrompt are called manually by AlarmService
  }

  // Test notification - fires in a few seconds
  Future<void> scheduleTestNotification() async {
    print('🧪 Showing immediate test notification...');
    
    try {
      // Show immediate notification
      await _notifications.show(
        999, // Different ID for test
        '🧪 Test Notification',
        'If you see this, notifications are working! Tap to open app.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ Test notification shown successfully');
      
      // Also schedule one for 30 seconds from now to test scheduling
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(seconds: 30));
      
      print('📅 Also scheduling notification for 30 seconds: $scheduledDate');
      
      // Check if we can use exact alarms
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      bool canUseExactAlarms = false;
      if (androidImplementation != null) {
        canUseExactAlarms = await androidImplementation.canScheduleExactNotifications() ?? false;
      }
      
      print('⏰ Can schedule exact alarms for test: $canUseExactAlarms');
      
      await _notifications.zonedSchedule(
        998,
        '⏰ Scheduled Test',
        'This notification was scheduled 30 seconds ago',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: canUseExactAlarms 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('✅ Scheduled notification also set with mode: ${canUseExactAlarms ? "exact" : "inexact"}');
    } catch (e) {
      print('❌ Error with test notification: $e');
      rethrow;
    }
  }
}

