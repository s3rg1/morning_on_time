import 'package:flutter/material.dart';

class AppSettings {
  final TimeOfDay wakeUpTime;
  final TimeOfDay leaveHomeTime;
  final TimeOfDay arrivalDeadline;
  final int minutesBeforeLeaving1;
  final int minutesBeforeLeaving2;
  final int minutesBeforeArrival;
  final Set<int> activeDaysOfWeek; // 1=Mon, 2=Tue, ..., 7=Sun

  AppSettings({
    required this.wakeUpTime,
    required this.leaveHomeTime,
    required this.arrivalDeadline,
    this.minutesBeforeLeaving1 = 5, // PRD: Leave Home Soon fires 5 min before leave time
    this.minutesBeforeLeaving2 = 5, // Reserved for future use
    this.minutesBeforeArrival = 2, // PRD: Pre-Arrival Check fires 2 min before arrival
    Set<int>? activeDaysOfWeek,
  })  : activeDaysOfWeek = activeDaysOfWeek ?? {1, 2, 3, 4, 5}; // Default: Weekdays

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
  }) {
    return AppSettings(
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      leaveHomeTime: leaveHomeTime ?? this.leaveHomeTime,
      arrivalDeadline: arrivalDeadline ?? this.arrivalDeadline,
      minutesBeforeLeaving1: minutesBeforeLeaving1 ?? this.minutesBeforeLeaving1,
      minutesBeforeLeaving2: minutesBeforeLeaving2 ?? this.minutesBeforeLeaving2,
      minutesBeforeArrival: minutesBeforeArrival ?? this.minutesBeforeArrival,
      activeDaysOfWeek: activeDaysOfWeek ?? this.activeDaysOfWeek,
    );
  }

  /// Checks if alarms should be scheduled for the given date.
  /// Returns true if the weekday is in activeDaysOfWeek.
  bool isActiveOnDate(DateTime date) {
    // Check if this day of the week is active (1=Mon, 2=Tue, ..., 7=Sun)
    return activeDaysOfWeek.contains(date.weekday);
  }
}
