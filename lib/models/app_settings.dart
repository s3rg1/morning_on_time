import 'package:flutter/material.dart';

class AppSettings {
  final TimeOfDay wakeUpTime;
  final TimeOfDay leaveHomeTime;
  final TimeOfDay arrivalDeadline;
  final int minutesBeforeLeaving1;
  final int minutesBeforeLeaving2;
  final int minutesBeforeArrival;

  AppSettings({
    required this.wakeUpTime,
    required this.leaveHomeTime,
    required this.arrivalDeadline,
    this.minutesBeforeLeaving1 = 10,
    this.minutesBeforeLeaving2 = 5,
    this.minutesBeforeArrival = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'wakeUpTimeHour': wakeUpTime.hour,
      'wakeUpTimeMinute': wakeUpTime.minute,
      'leaveHomeTimeHour': leaveHomeTime.hour,
      'leaveHomeTimeMinute': leaveHomeTime.minute,
      'arrivalDeadlineHour': arrivalDeadline.hour,
      'arrivalDeadlineMinute': arrivalDeadline.minute,
      'minutesBeforeLeaving1': minutesBeforeLeaving1,
      'minutesBeforeLeaving2': minutesBeforeLeaving2,
      'minutesBeforeArrival': minutesBeforeArrival,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      wakeUpTime: TimeOfDay(
        hour: json['wakeUpTimeHour'] as int,
        minute: json['wakeUpTimeMinute'] as int,
      ),
      leaveHomeTime: TimeOfDay(
        hour: json['leaveHomeTimeHour'] as int,
        minute: json['leaveHomeTimeMinute'] as int,
      ),
      arrivalDeadline: TimeOfDay(
        hour: json['arrivalDeadlineHour'] as int,
        minute: json['arrivalDeadlineMinute'] as int,
      ),
      minutesBeforeLeaving1: json['minutesBeforeLeaving1'] as int? ?? 10,
      minutesBeforeLeaving2: json['minutesBeforeLeaving2'] as int? ?? 5,
      minutesBeforeArrival: json['minutesBeforeArrival'] as int? ?? 5,
    );
  }

  AppSettings copyWith({
    TimeOfDay? wakeUpTime,
    TimeOfDay? leaveHomeTime,
    TimeOfDay? arrivalDeadline,
    int? minutesBeforeLeaving1,
    int? minutesBeforeLeaving2,
    int? minutesBeforeArrival,
  }) {
    return AppSettings(
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      leaveHomeTime: leaveHomeTime ?? this.leaveHomeTime,
      arrivalDeadline: arrivalDeadline ?? this.arrivalDeadline,
      minutesBeforeLeaving1: minutesBeforeLeaving1 ?? this.minutesBeforeLeaving1,
      minutesBeforeLeaving2: minutesBeforeLeaving2 ?? this.minutesBeforeLeaving2,
      minutesBeforeArrival: minutesBeforeArrival ?? this.minutesBeforeArrival,
    );
  }
}
