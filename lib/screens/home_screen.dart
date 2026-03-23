import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';
import '../services/alarm_service.dart';
import '../services/analytics_service.dart';
import '../utils/volume_utils.dart';
import '../widgets/journey_card.dart';
import '../widgets/next_alarm_indicator.dart';
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
  JourneyPhase _lastJourneyPhase = JourneyPhase.idle;

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
      final appState = Provider.of<AppState>(context, listen: false);
      VolumeUtils.checkVolumeAndWarn(
        context,
        checkSetupComplete: () => appState.isSetupComplete,
      );
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
      // Refresh notification banner from SharedPreferences
      final appState = Provider.of<AppState>(context, listen: false);
      appState.refreshLastJourneyNotification();
    }
  }

  Future<void> _checkJourneyState() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.checkAndRestoreJourneyState();
  }

  Map<String, dynamic> _getStreakLevelInfo(int streak) {
    final loc = AppLocalizations.of(context)!;
    if (streak < 10) {
      return {
        'image': 'assets/images/streak/level_0.png',
        'color': Colors.orange,
        'level': loc.streakLevelBeginner,
        'next': 10,
      };
    } else if (streak < 20) {
      return {
        'image': 'assets/images/streak/level_1.png',
        'color': Colors.green,
        'level': loc.streakLevelOccasional,
        'next': 20,
      };
    } else if (streak < 30) {
      return {
        'image': 'assets/images/streak/level_2.png',
        'color': Colors.purple,
        'level': loc.streakLevelPro,
        'next': 30,
      };
    } else if (streak < 40) {
      return {
        'image': 'assets/images/streak/level_3.png',
        'color': Colors.red,
        'level': loc.streakLevelChampion,
        'next': 40,
      };
    } else {
      return {
        'image': 'assets/images/streak/level_4.png',
        'color': Colors.amber.shade700,
        'level': loc.streakLevelUltimate,
        'next': null,
      };
    }
  }

  void _startJourneyStateMonitoring() {
    // Check every 5 seconds for journey state changes
    _journeyCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      
      final appState = Provider.of<AppState>(context, listen: false);
      final phase = appState.currentJourneyPhase;
      
      // Refresh notification banner from SharedPreferences
      appState.refreshLastJourneyNotification();
      
      // If journey phase changed, trigger a rebuild
      if (phase != _lastJourneyPhase) {
        print('🔄 Journey phase changed: $_lastJourneyPhase → $phase');

        // Log journey_started when transitioning from idle to gettingReady
        if (_lastJourneyPhase == JourneyPhase.idle &&
            phase == JourneyPhase.gettingReady) {
          AnalyticsService.logJourneyStarted();
        }

        _lastJourneyPhase = phase;
        setState(() {}); // Force rebuild to show/hide journey card
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

  void _showTestMenu(BuildContext context, AppState appState) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.testAllAlarms),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.testAllAlarmsDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              loc.testAllAlarmsDetails,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
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
            child: Text(loc.startTest),
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
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.testCannotRunMidnight(minutesUntilMidnight),
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
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.testStarted,
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 7),
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

  Future<void> _simulateRewardAchievement(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final completed = await appState.forceCompleteCurrentRewardForTesting();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? '🧪 Reward marked as achieved for testing. Check home badge and monthly view.'
              : 'No active reward found to complete.',
        ),
        backgroundColor: completed ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getTimeGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
        title: Text(
          _getTimeGreeting(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.green, size: 20),
              ),
              tooltip: 'Simulate Reward Achieved',
              onPressed: () => _simulateRewardAchievement(context),
            ),
          if (kDebugMode)
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: const Icon(Icons.calendar_month, color: Color(0xFF1CB0F6), size: 18),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(Icons.tune, color: Colors.grey.shade600, size: 18),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
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

                // Journey Card - shows during Getting Ready or On the Way (ABOVE streak/reward per PRD)
                if (appState.currentJourneyPhase != JourneyPhase.idle &&
                    appState.todayWakeUpTime != null &&
                    appState.todayLeaveTime != null &&
                    appState.arrivalDeadline != null) ...[
                  JourneyCard(
                    phase: appState.currentJourneyPhase,
                    wakeUpTime: appState.todayWakeUpTime!,
                    leaveTime: appState.todayLeaveTime!,
                    arrivalDeadline: appState.arrivalDeadline!,
                    lastNotification: appState.lastJourneyNotification,
                    onArrivalPressed: () => _showArrivalDialog(context, appState),
                  ),
                  const SizedBox(height: 16),
                ],

                // Idle state: next alarm indicator + today's result (ABOVE streak/reward per PRD)
                if (appState.currentJourneyPhase == JourneyPhase.idle) ...[
                  if (settings != null) ...[
                    Center(child: NextAlarmIndicator(settings: settings)),
                    const SizedBox(height: 16),
                  ],

                  // Today's Result - Show completion status if available
                  if (todayRecord != null) ...[
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
                                    todayRecord.wasOnTime 
                                        ? '✨ ${AppLocalizations.of(context)!.keepUpGreatWork}'
                                        : '💪 ${AppLocalizations.of(context)!.tryAgainTomorrow}',
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
                    const SizedBox(height: 16),
                  ],
                ],

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
                                  AppLocalizations.of(context)!.daysUntilNextLevel(daysToNext),
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
                const SizedBox(height: 16),
                const RewardCard(),

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
              '${AppLocalizations.of(context)!.arrivalTime} ${DateFormat('HH:mm').format(now)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await appState.confirmArrival(isOnTime);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
              
              // Celebrate success with confetti!
              if (isOnTime) {
                _confettiController.play();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }
}


