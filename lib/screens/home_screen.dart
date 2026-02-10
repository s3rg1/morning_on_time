import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:confetti/confetti.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:async';
import 'dart:math';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';
import '../models/check_in_status.dart';
import '../services/alarm_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/reward_card.dart';
import 'monthly_view_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late ConfettiController _confettiController;
  Timer? _journeyCheckTimer;
  bool _wasJourneyActive = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addObserver(this);
    
    // Start periodic timer to check journey state changes
    _startJourneyStateMonitoring();
    
    // Check journey state immediately when screen loads
    // This ensures countdown appears even if user opens app directly (not via notification tap)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomeScreen loaded - checking journey state...');
      _checkJourneyState();
      // Check volume if user has completed setup
      _checkVolumeIfSetupComplete();
    });
  }

  @override
  void dispose() {
    _journeyCheckTimer?.cancel();
    _confettiController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back from background - check if journey was started
      print('🔄 App resumed - checking journey state...');
      _checkJourneyState();
    }
  }

  Future<void> _checkJourneyState() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.checkAndRestoreJourneyState();
  }

  Future<void> _checkVolumeIfSetupComplete() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // Only check volume if user has completed setup (has scheduled notifications)
      if (!appState.isSetupComplete) {
        return;
      }
      
      final volume = await VolumeController().getVolume();
      
      // Warn if volume is below 30%
      if (volume < 0.3 && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.volume_down, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text('Low Volume'),
              ],
            ),
            content: Text(
              'Your media volume is at ${(volume * 100).round()}%.\n\n'
              'Consider increasing it to hear morning voice messages.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK, I'll adjust it"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Silently fail if volume check is not available
      print('Volume check failed: $e');
    }
  }

  Map<String, dynamic> _getStreakLevelInfo(int streak) {
    if (streak < 10) {
      return {
        'image': 'assets/images/streak/level_0.png',
        'color': Colors.orange,
        'level': 'Beginner Runner',
        'next': 10,
      };
    } else if (streak < 20) {
      return {
        'image': 'assets/images/streak/level_1.png',
        'color': Colors.green,
        'level': 'Occasional Runner',
        'next': 20,
      };
    } else if (streak < 30) {
      return {
        'image': 'assets/images/streak/level_2.png',
        'color': Colors.purple,
        'level': 'Pro Runner',
        'next': 30,
      };
    } else if (streak < 40) {
      return {
        'image': 'assets/images/streak/level_3.png',
        'color': Colors.red,
        'level': 'Champion Runner',
        'next': 40,
      };
    } else {
      return {
        'image': 'assets/images/streak/level_4.png',
        'color': Colors.amber.shade700,
        'level': 'Ultimate Jaguar',
        'next': null,
      };
    }
  }

  void _startJourneyStateMonitoring() {
    // Check every 5 seconds for journey state changes
    _journeyCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      
      final appState = Provider.of<AppState>(context, listen: false);
      final isActive = appState.isJourneyActive;
      
      // If journey state changed, trigger a rebuild
      if (isActive != _wasJourneyActive) {
        print('🔄 Journey state changed: $_wasJourneyActive → $isActive');
        _wasJourneyActive = isActive;
        setState(() {}); // Force rebuild to show/hide countdown
      }
    });
  }

  Future<bool> _checkExactAlarmPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final androidImplementation = plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final canSchedule = await androidImplementation.canScheduleExactNotifications() ?? false;
      print('🔍 Exact alarm permission status: $canSchedule');
      return canSchedule;
    }
    print('🔍 Not on Android, assuming permission granted');
    return true; // For iOS or other platforms
  }

  Future<void> _openExactAlarmSettings() async {
    print('🔧 Opening exact alarm settings...');
    final plugin = FlutterLocalNotificationsPlugin();
    final androidImplementation = plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> _testNotification(BuildContext context) async {
    print('🧪 Testing notification system...');
    
    final canSchedule = await _checkExactAlarmPermission();
    
    if (!canSchedule) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Cannot schedule notifications - permission not granted!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      await _openExactAlarmSettings();
    } else {
      // Schedule a test notification
      final appState = Provider.of<AppState>(context, listen: false);
      
      try {
        await appState.notificationService.scheduleTestNotification();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Showing test NOW! Scheduled test in 30s. KEEP APP OPEN and watch for it!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        print('❌ Error scheduling test: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showTestMenu(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🧪 Test All Alarms (22-Minute Journey)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This will test ALL alarm types in ~22 minutes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '✅ Wake-up alarm (T+2 min)\n'
              '✅ Checkpoint alarm #1 (T+12 min)\n'
              '✅ Leave Home Soon (T+13 min)\n'
              '✅ Leave Home → countdown starts (T+18 min)\n'
              '✅ Pre-Arrival Check (T+20 min)\n'
              '✅ Arrival deadline (T+22 min)\n\n'
              'Tap "Arrived" before deadline to test success path.\n'
              'Let timer expire to test failure path.\n\n'
              '⚠️ Cannot run between 11:38 PM - midnight.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startBackgroundTest(context, appState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('🚀 Start Test'),
          ),
        ],
      ),
    );
  }

  void _startBackgroundTest(BuildContext context, AppState appState) async {
    print('🧪 Starting comprehensive test - all alarm types will fire...');
    
    try {
      final now = DateTime.now();
      
      // Check if we're too close to midnight (test crosses midnight boundary)
      final midnight = DateTime(now.year, now.month, now.day + 1);
      final minutesUntilMidnight = midnight.difference(now).inMinutes;
      
      if (minutesUntilMidnight < 22) {
        print('❌ Test cannot run - too close to midnight ($minutesUntilMidnight min until midnight)');
        print('💡 Test requires 22 minutes but only $minutesUntilMidnight minutes until midnight');
        print('💡 Please run test earlier in the day (before 11:38 PM)');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Test cannot run - too close to midnight!\n'
                'Only $minutesUntilMidnight minutes until midnight.\n'
                'Test needs 22 minutes. Please try earlier in the day.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // 1. Clear today's result and reset arrival confirmation
      await appState.resetArrivalConfirmation();
      print('🧪 Reset arrival_confirmed flag for testing');
      
      // 2. Create compressed timeline that triggers ALL alarms
      // Important: TimeOfDay loses seconds precision, so we must round to next minute
      // to ensure alarm times are always in the future
      
      // Calculate base time - round to +2 minutes to account for async scheduling delay
      // (1 minute buffer was too tight - scheduling code runs DateTime.now() again)
      final baseTime = DateTime(now.year, now.month, now.day, now.hour, now.minute).add(const Duration(minutes: 2));
      
      // Wake-up: +2 minutes (ensures safe buffer for async scheduling)
      // Leave: wake + 16 min (ensures checkpoint schedules: cutoff = wake + 11 min > wake + 10 min)
      // Arrival: wake + 20 min (4-minute journey)
      // Note: Use full minutes only - TimeOfDay strips seconds!
      
      final wakeUpTime = baseTime;
      final leaveTime = baseTime.add(const Duration(minutes: 16));
      final arrivalTime = baseTime.add(const Duration(minutes: 20));
      
      // Set test deadline BEFORE saving settings
      appState.setTestDeadline(arrivalTime);
      print('🧪 Test deadline set: $arrivalTime');
      
      // Use standard saveSettings() with test times - no special logic needed!
      // minutesBeforeLeaving1 and minutesBeforeArrival use PRD-compliant defaults (5 and 2)
      final testSettings = AppSettings(
        wakeUpTime: TimeOfDay(hour: wakeUpTime.hour, minute: wakeUpTime.minute),
        leaveHomeTime: TimeOfDay(hour: leaveTime.hour, minute: leaveTime.minute),
        arrivalDeadline: TimeOfDay(hour: arrivalTime.hour, minute: arrivalTime.minute),
        activeDaysOfWeek: {1, 2, 3, 4, 5, 6, 7}, // Test works on ANY day
      );
      
      print('🧪 Compressed test timeline:');
      print('  Wake-up:  $wakeUpTime (T+2 min)');
      print('  Leave:    $leaveTime (T+18 min)');
      print('  Arrival:  $arrivalTime (T+22 min)');
      print('🧪 Test overrides: activeDaysOfWeek = ALL DAYS (works on any day including weekends)');
      print('🧪 Expected alarms:');
      print('  T+02:00 - Wake-up alarm');
      print('  T+12:00 - Checkpoint #1');
      print('  T+13:00 - Leave Home Soon');
      print('  T+18:00 - Leave Home (countdown starts)');
      print('  T+20:00 - Pre-Arrival Check');
      print('  T+22:00 - Arrival deadline');
      
      // 3. Save settings - triggers standard alarm scheduling
      await appState.saveSettings(testSettings);
      print('🧪 Test settings saved - all alarms scheduled via standard flow');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🧪 Test Started! (22-minute journey)\n'
              '• Wake-up: in 2 minutes\n'
              '• Checkpoint #1: in 12 minutes (NEW!)\n'
              '• Leave Home Soon: in 13 minutes\n'
              '• Leave Home: in 18 minutes → countdown starts\n'
              '• Pre-Arrival Check: in 20 minutes\n'
              '• Arrival deadline: in 22 minutes\n'
              '• Stay on screen to observe alarms firing',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 7),
          ),
        );
      }
    } catch (e) {
      print('❌ Error setting up test: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Find the next active day with scheduled alarms
  DateTime? _findNextActiveDay(AppSettings settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check today first - if we haven't passed arrival deadline and it's active
    if (settings.isActiveOnDate(today)) {
      final arrivalTime = DateTime(
        today.year,
        today.month,
        today.day,
        settings.arrivalDeadline.hour,
        settings.arrivalDeadline.minute,
      );
      
      if (now.isBefore(arrivalTime)) {
        return today;
      }
    }
    
    // Check next 7 days
    for (int i = 1; i <= 7; i++) {
      final checkDate = today.add(Duration(days: i));
      if (settings.isActiveOnDate(checkDate)) {
        return checkDate;
      }
    }
    
    return null; // No active days in next 7 days
  }

  /// Get pending alarms for a specific date (only wake/leave/arrival that haven't passed)
  List<Map<String, dynamic>> _getPendingAlarms(DateTime date, AppSettings settings) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    final alarms = <Map<String, dynamic>>[];
    
    // Wake-up
    final wakeUpTime = DateTime(
      date.year,
      date.month,
      date.day,
      settings.wakeUpTime.hour,
      settings.wakeUpTime.minute,
    );
    
    if (!isToday || now.isBefore(wakeUpTime)) {
      alarms.add({
        'icon': Icons.wb_sunny,
        'label': 'Wake up at:',
        'time': wakeUpTime,
      });
    }
    
    // Leave home
    final leaveTime = DateTime(
      date.year,
      date.month,
      date.day,
      settings.leaveHomeTime.hour,
      settings.leaveHomeTime.minute,
    );
    
    if (!isToday || now.isBefore(leaveTime)) {
      alarms.add({
        'icon': Icons.logout,
        'label': 'Leave at:',
        'time': leaveTime,
      });
    }
    
    // Arrival
    final arrivalTime = DateTime(
      date.year,
      date.month,
      date.day,
      settings.arrivalDeadline.hour,
      settings.arrivalDeadline.minute,
    );
    
    if (!isToday || now.isBefore(arrivalTime)) {
      alarms.add({
        'icon': Icons.school,
        'label': 'Arrive by:',
        'time': arrivalTime,
      });
    }
    
    return alarms;
  }

  /// Get mission header based on date
  String _getMissionHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return "Today's Mission: Arrive on time!";
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return "Tomorrow's Mission: Arrive on time!";
    } else {
      final weekday = DateFormat('EEEE').format(date); // Full weekday name
      final monthDay = DateFormat('MMM d').format(date); // Abbreviated month + day
      return "$weekday, $monthDay Mission: Arrive on time!";
    }
  }

  /// Build the mission frame widget with Timeline Journey design
  Widget _buildMissionFrame(AppSettings settings) {
    final nextDay = _findNextActiveDay(settings);
    
    if (nextDay == null) {
      // No active days in next 7 days
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.event_busy, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No upcoming journeys',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your settings to enable active days',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    final pendingAlarms = _getPendingAlarms(nextDay, settings);
    final header = _getMissionHeader(nextDay);
    
    if (pendingAlarms.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Duolingo-inspired Timeline Journey design
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9600), // Bright orange
            Color(0xFFFFC837), // Bright yellow
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mission header with emoji
            Row(
              children: [
                const Text(
                  '🎯',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Timeline visualization
            _buildTimeline(pendingAlarms),
            
            const SizedBox(height: 24),
            
            // Alarm details
            ...pendingAlarms.map((alarm) => _buildAlarmRow(alarm)),
            
            const SizedBox(height: 16),
            
            // Motivational message
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '💪',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getMotivationalMessage(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build visual timeline
  Widget _buildTimeline(List<Map<String, dynamic>> alarms) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < alarms.length; i++) ...[
          // Timeline dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
          // Connector line (except after last item)
          if (i < alarms.length - 1)
            Container(
              width: 40,
              height: 3,
              color: Colors.white.withOpacity(0.5),
            ),
        ],
      ],
    );
  }
  
  /// Build individual alarm row
  Widget _buildAlarmRow(Map<String, dynamic> alarm) {
    final IconData icon = alarm['icon'] as IconData;
    final String label = (alarm['label'] as String).replaceAll(' at:', '').replaceAll(' by:', '');
    final DateTime time = alarm['time'] as DateTime;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Icon with white background circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFFFF9600),
            ),
          ),
          const SizedBox(width: 16),
          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Time - LARGE and BOLD
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              DateFormat.jm().format(time),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9600),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get random motivational message
  String _getMotivationalMessage() {
    final messages = [
      "You've got this!",
      "Let's do this!",
      "Ready to succeed!",
      "Time to shine!",
      "You can do it!",
    ];
    return messages[DateTime.now().second % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Test button (remove in production)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
              ),
              child: const Icon(Icons.science, color: Color(0xFFFF9600), size: 20),
            ),
            tooltip: 'Test Countdown',
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              _showTestMenu(context, appState);
            },
          ),
          // Monthly history view button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
              ),
              child: const Icon(Icons.calendar_month, color: Color(0xFF1CB0F6), size: 20),
            ),
            tooltip: 'Monthly History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MonthlyViewScreen()),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(Icons.settings, color: Colors.grey.shade700, size: 20),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayRecord = appState.getTodayRecord();
          final settings = appState.settings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Permission Warning Banner
                FutureBuilder<bool>(
                  future: _checkExactAlarmPermission(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data!) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade100,
                              Colors.orange.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Alarm Permission Required',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Morning notifications won\'t work without this permission. '
                                'Tap below to enable it in your device settings.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _openExactAlarmSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.settings, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Enable Alarm Permission',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                
                // Streak Card with Level-Up Character (Duolingo style)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Builder(
                      builder: (context) {
                        final levelInfo = _getStreakLevelInfo(appState.currentStreak);
                        final daysToNext = levelInfo['next'] != null 
                            ? levelInfo['next'] - appState.currentStreak 
                            : null;
                        
                        return Column(
                          children: [
                            // Character with colored circle background
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Colored circle background
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (levelInfo['color'] as Color).withOpacity(0.2),
                                    border: Border.all(
                                      color: levelInfo['color'] as Color,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                // Character image
                                Image.asset(
                                  levelInfo['image'] as String,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                // Fire badge overlay
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          size: 20,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${appState.currentStreak}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Streak text
                            Text(
                              AppLocalizations.of(context)!.daysStreak(appState.currentStreak),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Level name
                            Text(
                              levelInfo['level'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: levelInfo['color'] as Color,
                              ),
                            ),
                            // Progress to next level
                            if (daysToNext != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: (levelInfo['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  daysToNext == 1
                                      ? '1 day until next level! 🎉'
                                      : '$daysToNext days until next level! 🚀',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: levelInfo['color'] as Color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Maximum level reached! 🏆',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Reward Card - Below streak card
                const RewardCard(),

                const SizedBox(height: 24),

                // Journey Status - Show countdown if journey is active
                if (appState.isJourneyActive && appState.arrivalDeadline != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF58CC02), // Bright green
                          Color(0xFF46A302), // Darker green
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🏃',
                                style: TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.journeyInProgress,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CountdownTimer(
                            arrivalDeadline: appState.arrivalDeadline!,
                            totalDuration: appState.arrivalDeadline!.difference(
                              DateTime(
                                appState.arrivalDeadline!.year,
                                appState.arrivalDeadline!.month,
                                appState.arrivalDeadline!.day,
                                appState.settings!.leaveHomeTime.hour,
                                appState.settings!.leaveHomeTime.minute,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _showArrivalDialog(context, appState);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF58CC02),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.arrivedAtSchool,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Today's Result - Show completion status if available
                if (todayRecord != null && !appState.isJourneyActive) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: todayRecord.wasOnTime
                            ? [
                                const Color(0xFF58CC02),
                                const Color(0xFF46A302),
                              ]
                            : [
                                const Color(0xFFFF4B4B),
                                const Color(0xFFE03E3E),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (todayRecord.wasOnTime ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              todayRecord.wasOnTime ? Icons.check_circle : Icons.cancel,
                              size: 40,
                              color: todayRecord.wasOnTime ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todayRecord.wasOnTime
                                      ? AppLocalizations.of(context)!.greatJob
                                      : AppLocalizations.of(context)!.didntMakeIt,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todayRecord.wasOnTime ? '✨ Keep up the great work!' : '💪 Try again tomorrow!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Mission Frame - Dynamic display showing next active day's pending alarms
                if (!appState.isJourneyActive && settings != null) ...[
                  const SizedBox(height: 16),
                  _buildMissionFrame(settings),
                  const SizedBox(height: 24),
                ],

              ],
            ),
          );
        },
      ),        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Down
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.orange,
              Colors.pink,
              Colors.purple,
            ],
          ),
        ),
      ],    );
  }

  void _showArrivalDialog(BuildContext context, AppState appState) {
    final settings = appState.settings;
    if (settings == null) return;

    final now = DateTime.now();
    final deadline = DateTime(
      now.year,
      now.month,
      now.day,
      settings.arrivalDeadline.hour,
      settings.arrivalDeadline.minute,
    );

    final isOnTime = now.isBefore(deadline) || now.isAtSameMomentAs(deadline);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.arrivalConfirmation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnTime ? Icons.check_circle : Icons.info,
              size: 64,
              color: isOnTime ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isOnTime
                  ? AppLocalizations.of(context)!.arrivedOnTime
                  : AppLocalizations.of(context)!.arrivedLate,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Arrival time: ${DateFormat('HH:mm').format(now)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.confirmArrival(isOnTime);
              Navigator.of(ctx).pop();
              
              // Celebrate success with confetti!
              if (isOnTime) {
                _confettiController.play();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}


