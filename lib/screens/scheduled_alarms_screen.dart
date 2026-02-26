import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Alarms (7-Day Window)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_ManifestSnapshot>(
        future: _loadManifestSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final manifestSnapshot = snapshot.data ?? _ManifestSnapshot(alarms: [], updatedAt: null);
          final alarms = manifestSnapshot.alarms;

          if (alarms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No planned alarms found yet.\nSave settings to schedule alarms and refresh this screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
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
                          'Real scheduled alarms manifest',
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
                        const SizedBox(height: 4),
                        Text(
                          'Last update: ${_formatTimestamp(manifestSnapshot.updatedAt)}',
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
          );
        },
      ),
    );
  }

  Future<_ManifestSnapshot> _loadManifestSnapshot() async {
    final storage = StorageService();
    final manifest = await storage.loadPlannedAlarmsManifest();
    final updatedAt = await storage.loadPlannedAlarmsManifestUpdatedAt();

    final alarms = manifest
        .map((entry) => AlarmInfo.fromJson(entry))
        .whereType<AlarmInfo>()
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return _ManifestSnapshot(alarms: alarms, updatedAt: updatedAt);
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'unknown';
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
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

  static AlarmInfo? fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as int;
      final name = json['name'] as String;
      final type = json['type'] as String;
      final date = DateTime.parse(json['date'] as String);
      return AlarmInfo(id: id, name: name, type: type, date: date);
    } catch (_) {
      return null;
    }
  }
}

class _ManifestSnapshot {
  final List<AlarmInfo> alarms;
  final DateTime? updatedAt;

  _ManifestSnapshot({
    required this.alarms,
    required this.updatedAt,
  });
}
