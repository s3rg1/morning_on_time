import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/check_in_status.dart';
import '../services/alarm_service.dart';
import 'monthly_view_screen.dart';
import 'rewards_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
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
                
                // Streak Card
                Card(
                  elevation: 4,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 60, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text(
                          '${appState.currentStreak}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.daysStreak(appState.currentStreak),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Status
                if (todayRecord != null)
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
                  )
                else
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

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.star,
                        label: AppLocalizations.of(context)!.rewards,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RewardsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );
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
