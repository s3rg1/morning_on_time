import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:confetti/confetti.dart';
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
        title: const Text('🧪 Test Countdown Journey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This will simulate a real morning:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Clears today\'s result\n'
              '2. Wake-up: 15 min ago\n'
              '3. Leave time: in ~90 sec\n'
              '4. Arrival time: in 4 min\n'
              '5. All alarms scheduled (standard flow)\n'
              '6. Tap "Arrived" to succeed before time runs out',
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
    print('🧪 Starting test - setting up test environment...');
    
    try {
      final now = DateTime.now();
      
      // 1. Clear today's result if any
      final today = DateTime(now.year, now.month, now.day);
      // Note: We'll let the test overwrite any existing result naturally
      // when arrival confirmation happens
      print('🧪 Test will overwrite any existing result for today');
      
      // 2. Reset arrival confirmation flag for testing
      await appState.resetArrivalConfirmation();
      print('🧪 Reset arrival_confirmed flag for testing');
      
      // 3. Create test settings with times relative to now
      // Note: TimeOfDay only stores hour:minute, so we need enough buffer
      // to ensure times don't become "in the past" after conversion
      final wakeUpTime = now.subtract(const Duration(minutes: 15));
      final leaveTime = now.add(const Duration(seconds: 90)); // 1.5 min to survive TimeOfDay conversion
      final arrivalTime = now.add(const Duration(minutes: 4));
      
      // Set test deadline BEFORE saving settings
      appState.setTestDeadline(arrivalTime);
      print('🧪 Test deadline set BEFORE saving settings: $arrivalTime');
      
      final testSettings = AppSettings(
        wakeUpTime: TimeOfDay(hour: wakeUpTime.hour, minute: wakeUpTime.minute),
        leaveHomeTime: TimeOfDay(hour: leaveTime.hour, minute: leaveTime.minute),
        arrivalDeadline: TimeOfDay(hour: arrivalTime.hour, minute: arrivalTime.minute),
      );
      
      print('🧪 Test times:');
      print('  Wake-up: $wakeUpTime (15 min ago)');
      print('  Leave: $leaveTime (5 sec from now)');
      print('  Arrival: $arrivalTime (3 min from now)');
      
      // 4. Save settings - this will trigger standard alarm scheduling
      await appState.saveSettings(testSettings);
      print('🧪 Test settings saved and all alarms scheduled');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🧪 Test Started!\n'
              '• Leave Home alarm fires in ~90 seconds\n'
              '• Pre-Arrival Check in ~2 minutes\n'
              '• Arrival deadline in 4 minutes\n'
              '• Tap "Arrived at School" to succeed',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          // Test button (remove in production)
          IconButton(
            icon: const Icon(Icons.science, color: Colors.orange),
            tooltip: 'Test Countdown',
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              _showTestMenu(context, appState);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
          ),
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
                      return Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, 
                                    color: Colors.orange.shade700, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Alarm Permission Required',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Morning notifications won\'t work without this permission. '
                                'Tap below to enable it in your device settings.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _openExactAlarmSettings,
                                icon: const Icon(Icons.settings),
                                label: const Text('Enable Alarm Permission'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
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
                
                // Streak Card with Level-Up Character
                Card(
                  elevation: 4,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.journeyInProgress,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showArrivalDialog(context, appState);
                            },
                            icon: const Icon(Icons.school),
                            label: Text(AppLocalizations.of(context)!.arrivedAtSchool),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                  Card(
                    color: todayRecord.wasOnTime
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            todayRecord.wasOnTime ? Icons.check_circle : Icons.cancel,
                            size: 40,
                            color: todayRecord.wasOnTime ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              todayRecord.wasOnTime
                                  ? AppLocalizations.of(context)!.greatJob
                                  : AppLocalizations.of(context)!.didntMakeIt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Mission Card - Show only when journey is NOT active
                if (!appState.isJourneyActive) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.todaysMission,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.arriveOnTime,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (settings != null) ...[
                            const SizedBox(height: 20),
                            _ScheduleItem(
                              icon: Icons.alarm,
                              label: AppLocalizations.of(context)!.wakeUp,
                              time: settings.wakeUpTime.format(context),
                            ),
                            _ScheduleItem(
                              icon: Icons.directions_run,
                              label: AppLocalizations.of(context)!.leaveHome,
                              time: settings.leaveHomeTime.format(context),
                            ),
                            _ScheduleItem(
                              icon: Icons.school,
                              label: AppLocalizations.of(context)!.arriveBy,
                              time: settings.arrivalDeadline.format(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                _QuickActionButton(
                  icon: Icons.calendar_month,
                  label: AppLocalizations.of(context)!.monthlyView,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MonthlyViewScreen(),
                      ),
                    );
                  },
                ),

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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _ScheduleItem({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
