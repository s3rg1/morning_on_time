import 'package:flutter/material.dart';

class AppSettings {
  final TimeOfDay wakeUpTime;
  final TimeOfDay leaveHomeTime;
  final TimeOfDay arrivalDeadline;
  final int minutesBeforeLeaving1;
  final int minutesBeforeLeaving2;
  final int minutesBeforeArrival;
  final Set<int> activeDaysOfWeek; // 1=Mon, 2=Tue, ..., 7=Sun
  final Set<DateTime> skipDates; // Specific dates to skip alarms

  AppSettings({
    required this.wakeUpTime,
    required this.leaveHomeTime,
    required this.arrivalDeadline,
    this.minutesBeforeLeaving1 = 10,
    this.minutesBeforeLeaving2 = 5,
    this.minutesBeforeArrival = 5,
    Set<int>? activeDaysOfWeek,
    Set<DateTime>? skipDates,
  })  : activeDaysOfWeek = activeDaysOfWeek ?? {1, 2, 3, 4, 5}, // Default: Weekdays
        skipDates = skipDates ?? {};

  Map<String, dynamic> toJson() {
    return {
      'wakeUpTime_hour': wakeUpTime.hour,
      'wakeUpTime_minute': wakeUpTime.minute,
      'leaveHomeTime_hour': leaveHomeTime.hour,
      'leaveHomeTime_minute': leaveHomeTime.minute,
      'arrivalDeadline_hour': arrivalDeadline.hour,
      'arrivalDeadline_minute': arrivalDeadline.minute,
      'minutesBeforeLeaving1': minutesBeforeLeaving1,
      'minutesBeforeLeaving2': minutesBeforeLeaving2,
      'minutesBeforeArrival': minutesBeforeArrival,
      'activeDaysOfWeek': activeDaysOfWeek.toList(),
      'skipDates': skipDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // Parse activeDaysOfWeek with backward compatibility
    Set<int> parsedActiveDays = {1, 2, 3, 4, 5}; // Default: Weekdays
    if (json['activeDaysOfWeek'] != null) {
      parsedActiveDays = (json['activeDaysOfWeek'] as List<dynamic>)
          .map((e) => e as int)
          .toSet();
    }

    // Parse skipDates with backward compatibility
    Set<DateTime> parsedSkipDates = {};
    if (json['skipDates'] != null) {
      parsedSkipDates = (json['skipDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toSet();
      // Auto-cleanup: Remove past skip dates
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      parsedSkipDates.removeWhere((date) => date.isBefore(today));
    }

    return AppSettings(
      wakeUpTime: TimeOfDay(
        hour: json['wakeUpTime_hour'] as int,
        minute: json['wakeUpTime_minute'] as int,
      ),
      leaveHomeTime: TimeOfDay(
        hour: json['leaveHomeTime_hour'] as int,
        minute: json['leaveHomeTime_minute'] as int,
      ),
      arrivalDeadline: TimeOfDay(
        hour: json['arrivalDeadline_hour'] as int,
        minute: json['arrivalDeadline_minute'] as int,
      ),
      minutesBeforeLeaving1: json['minutesBeforeLeaving1'] as int? ?? 10,
      minutesBeforeLeaving2: json['minutesBeforeLeaving2'] as int? ?? 5,
      minutesBeforeArrival: json['minutesBeforeArrival'] as int? ?? 5,
      activeDaysOfWeek: parsedActiveDays,
      skipDates: parsedSkipDates,
    );
  }

  AppSettings copyWith({
    TimeOfDay? wakeUpTime,
    TimeOfDay? leaveHomeTime,
    TimeOfDay? arrivalDeadline,
    int? minutesBeforeLeaving1,
    int? minutesBeforeLeaving2,
    int? minutesBeforeArrival,
    Set<int>? activeDaysOfWeek,
    Set<DateTime>? skipDates,
  }) {
    return AppSettings(
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      leaveHomeTime: leaveHomeTime ?? this.leaveHomeTime,
      arrivalDeadline: arrivalDeadline ?? this.arrivalDeadline,
      minutesBeforeLeaving1: minutesBeforeLeaving1 ?? this.minutesBeforeLeaving1,
      minutesBeforeLeaving2: minutesBeforeLeaving2 ?? this.minutesBeforeLeaving2,
      minutesBeforeArrival: minutesBeforeArrival ?? this.minutesBeforeArrival,
      activeDaysOfWeek: activeDaysOfWeek ?? this.activeDaysOfWeek,
      skipDates: skipDates ?? this.skipDates,
    );
  }

  /// Checks if alarms should be scheduled for the given date.
  /// Returns false if the date is in skipDates or if the weekday is not in activeDaysOfWeek.
  bool isActiveOnDate(DateTime date) {
    // Normalize date to midnight for comparison (ignore time component)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Check if this specific date should be skipped
    if (skipDates.any((skipDate) {
      final normalizedSkipDate = DateTime(skipDate.year, skipDate.month, skipDate.day);
      return normalizedSkipDate == normalizedDate;
    })) {
      return false;
    }
    
    // Check if this day of the week is active (1=Mon, 2=Tue, ..., 7=Sun)
    return activeDaysOfWeek.contains(date.weekday);
  }
}
