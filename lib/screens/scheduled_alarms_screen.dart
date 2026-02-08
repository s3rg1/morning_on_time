import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';

class ScheduledAlarmsScreen extends StatelessWidget {
  const ScheduledAlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final settings = appState.settings;

    if (settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scheduled Alarms'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No settings configured'),
        ),
      );
    }

    final alarms = _buildAlarmList(settings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Alarms (7-Day Window)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: alarms.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No alarms scheduled.\nAll days in the 7-day window are inactive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header card
                  return Card(
                    color: Colors.blue[50],
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ${alarms.length} alarms',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Next 7 days • Active days only',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pattern: ${_formatActiveDays(settings.activeDaysOfWeek)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final alarm = alarms[index - 1];
                final isFirstOfDay = index == 1 || 
                    alarms[index - 1].date.day != alarms[index - 2].date.day;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstOfDay)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                        child: Text(
                          _formatDayHeader(alarm.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getAlarmColor(alarm.type),
                          child: Icon(
                            _getAlarmIcon(alarm.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          alarm.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'ID: ${alarm.id}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: Text(
                          _formatTime(alarm.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<AlarmInfo> _buildAlarmList(AppSettings settings) {
    final now = DateTime.now();
    final List<AlarmInfo> alarms = [];

    for (int dayOffset = 0; dayOffset <= 6; dayOffset++) {
      final targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
      
      // Check if this date is active
      if (!settings.isActiveOnDate(targetDate)) {
        continue;
      }

      // Calculate alarm times for this date
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

      // 1. Wake-up alarm
      final wakeUpId = (dayOffset * 1000) + 1;
      if (wakeUpTime.isAfter(now.add(const Duration(minutes: 2)))) {
        alarms.add(AlarmInfo(
          id: wakeUpId,
          name: '🌅 Wake-up',
          type: 'wake-up',
          date: wakeUpTime,
        ));
      }

      // 2. Checkpoint alarms
      final cutoffTime = leaveHomeTime.subtract(const Duration(minutes: 5));
      DateTime nextCheckIn = wakeUpTime.add(const Duration(minutes: 10));
      int checkpointIndex = 0;

      while (nextCheckIn.isBefore(cutoffTime) && checkpointIndex < 20) {
        final checkpointId = (dayOffset * 1000) + 100 + checkpointIndex;
        
        if (nextCheckIn.isAfter(now.add(const Duration(minutes: 2)))) {
          alarms.add(AlarmInfo(
            id: checkpointId,
            name: '⏰ Checkpoint #${checkpointIndex + 1}',
            type: 'checkpoint',
            date: nextCheckIn,
          ));
        }
        
        nextCheckIn = nextCheckIn.add(const Duration(minutes: 10));
        checkpointIndex++;
      }

      // 3. Leave-home-soon alarm
      final leaveHomeSoonTime = leaveHomeTime.subtract(Duration(minutes: settings.minutesBeforeLeaving1));
      final leaveHomeSoonId = (dayOffset * 1000) + 3;
      if (leaveHomeSoonTime.isAfter(now.add(const Duration(minutes: 2)))) {
        alarms.add(AlarmInfo(
          id: leaveHomeSoonId,
          name: '🏃 Leave-soon',
          type: 'leave-soon',
          date: leaveHomeSoonTime,
        ));
      }

      // 4. Leave-home alarm
      final leaveHomeId = (dayOffset * 1000) + 4;
      if (leaveHomeTime.isAfter(now)) {
        alarms.add(AlarmInfo(
          id: leaveHomeId,
          name: '🚪 Leave-home',
          type: 'leave-home',
          date: leaveHomeTime,
        ));
      }

      // 5. Arrival-check alarm
      final arrivalCheckTime = arrivalDeadline.subtract(Duration(minutes: settings.minutesBeforeArrival));
      final arrivalCheckId = (dayOffset * 1000) + 5;
      if (arrivalCheckTime.isAfter(now.add(const Duration(seconds: 30)))) {
        alarms.add(AlarmInfo(
          id: arrivalCheckId,
          name: '🎯 Arrival-check',
          type: 'arrival-check',
          date: arrivalCheckTime,
        ));
      }

      // 6. Arrival alarm
      final arrivalId = (dayOffset * 1000) + 6;
      if (arrivalDeadline.isAfter(now.add(const Duration(minutes: 1)))) {
        alarms.add(AlarmInfo(
          id: arrivalId,
          name: '⌛ Arrival',
          type: 'arrival',
          date: arrivalDeadline,
        ));
      }
    }

    // Sort by date+time ascending
    alarms.sort((a, b) => a.date.compareTo(b.date));

    return alarms;
  }

  String _formatActiveDays(Set<int> activeDays) {
    if (activeDays.length == 7) return 'Every day';
    if (activeDays.length == 5 && activeDays.containsAll([1, 2, 3, 4, 5])) {
      return 'Weekdays only';
    }
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = activeDays.toList()..sort();
    return sortedDays.map((d) => dayNames[d - 1]).join(', ');
  }

  String _formatDayHeader(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDay = DateTime(date.year, date.month, date.day);
    
    String dayLabel;
    if (targetDay == today) {
      dayLabel = 'Today';
    } else if (targetDay == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = weekdays[date.weekday - 1];
    }
    
    return '$dayLabel, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getAlarmColor(String type) {
    switch (type) {
      case 'wake-up':
        return Colors.orange;
      case 'checkpoint':
        return Colors.blue;
      case 'leave-soon':
        return Colors.amber;
      case 'leave-home':
        return Colors.red;
      case 'arrival-check':
        return Colors.green;
      case 'arrival':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlarmIcon(String type) {
    switch (type) {
      case 'wake-up':
        return Icons.wb_sunny;
      case 'checkpoint':
        return Icons.access_time;
      case 'leave-soon':
        return Icons.directions_run;
      case 'leave-home':
        return Icons.exit_to_app;
      case 'arrival-check':
        return Icons.check_circle_outline;
      case 'arrival':
        return Icons.school;
      default:
        return Icons.alarm;
    }
  }
}

class AlarmInfo {
  final int id;
  final String name;
  final String type;
  final DateTime date;

  AlarmInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
  });
}
