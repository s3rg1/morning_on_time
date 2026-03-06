import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';

/// Compact indicator showing when the next wake-up alarm will fire.
class NextAlarmIndicator extends StatelessWidget {
  final AppSettings settings;

  const NextAlarmIndicator({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find next active day with a wake-up in the future
    DateTime? nextWakeUp;
    for (int i = 0; i <= 7; i++) {
      final day = today.add(Duration(days: i));
      if (!settings.isActiveOnDate(day)) continue;
      final wakeUp = DateTime(
        day.year, day.month, day.day,
        settings.wakeUpTime.hour, settings.wakeUpTime.minute,
      );
      if (wakeUp.isAfter(now)) {
        nextWakeUp = wakeUp;
        break;
      }
    }

    if (nextWakeUp == null) {
      return _buildChip(
        context,
        Icons.alarm_off,
        loc.noUpcomingAlarms,
        Colors.grey,
      );
    }

    final diff = nextWakeUp.difference(now);
    final isToday = nextWakeUp.day == now.day && nextWakeUp.month == now.month;

    String label;
    if (isToday || diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final timeParts = <String>[];
      if (hours > 0) timeParts.add('${hours}h');
      if (minutes > 0 || hours == 0) timeParts.add('${minutes}m');
      label = loc.nextAlarmIn(timeParts.join(' '));
    } else {
      label = loc.nextAlarmTomorrow(DateFormat.jm().format(nextWakeUp));
    }

    return _buildChip(context, Icons.alarm, label, Colors.blue);
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
