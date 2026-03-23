import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morning_on_time/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    late AppSettings settings;

    setUp(() {
      settings = AppSettings(
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        leaveHomeTime: const TimeOfDay(hour: 8, minute: 0),
        arrivalDeadline: const TimeOfDay(hour: 9, minute: 0),
      );
    });

    group('constructor', () {
      test('uses default values for optional parameters', () {
        expect(settings.minutesBeforeLeaving1, 5);
        expect(settings.minutesBeforeLeaving2, 5);
        expect(settings.minutesBeforeArrival, 2);
        expect(settings.activeDaysOfWeek, {1, 2, 3, 4, 5});
      });

      test('accepts custom values for optional parameters', () {
        final custom = AppSettings(
          wakeUpTime: const TimeOfDay(hour: 6, minute: 30),
          leaveHomeTime: const TimeOfDay(hour: 7, minute: 30),
          arrivalDeadline: const TimeOfDay(hour: 8, minute: 30),
          minutesBeforeLeaving1: 10,
          minutesBeforeLeaving2: 3,
          minutesBeforeArrival: 5,
          activeDaysOfWeek: {1, 2, 3, 4, 5, 6, 7},
        );

        expect(custom.minutesBeforeLeaving1, 10);
        expect(custom.minutesBeforeLeaving2, 3);
        expect(custom.minutesBeforeArrival, 5);
        expect(custom.activeDaysOfWeek, {1, 2, 3, 4, 5, 6, 7});
      });
    });

    group('toJson / fromJson', () {
      test('roundtrips correctly', () {
        final json = settings.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.wakeUpTime.hour, settings.wakeUpTime.hour);
        expect(restored.wakeUpTime.minute, settings.wakeUpTime.minute);
        expect(restored.leaveHomeTime.hour, settings.leaveHomeTime.hour);
        expect(restored.leaveHomeTime.minute, settings.leaveHomeTime.minute);
        expect(restored.arrivalDeadline.hour, settings.arrivalDeadline.hour);
        expect(restored.arrivalDeadline.minute, settings.arrivalDeadline.minute);
        expect(restored.activeDaysOfWeek, settings.activeDaysOfWeek);
      });

      test('toJson produces expected keys', () {
        final json = settings.toJson();

        expect(json['wakeUpTime_hour'], 7);
        expect(json['wakeUpTime_minute'], 0);
        expect(json['leaveHomeTime_hour'], 8);
        expect(json['leaveHomeTime_minute'], 0);
        expect(json['arrivalDeadline_hour'], 9);
        expect(json['arrivalDeadline_minute'], 0);
        expect(json['minutesBeforeLeaving1'], 5);
        expect(json['minutesBeforeLeaving2'], 5);
        expect(json['minutesBeforeArrival'], 2);
        expect(json['activeDaysOfWeek'], isA<List>());
      });

      test('fromJson handles missing optional fields with defaults', () {
        final json = {
          'wakeUpTime_hour': 6,
          'wakeUpTime_minute': 30,
          'leaveHomeTime_hour': 7,
          'leaveHomeTime_minute': 30,
          'arrivalDeadline_hour': 8,
          'arrivalDeadline_minute': 30,
        };

        final restored = AppSettings.fromJson(json);

        expect(restored.minutesBeforeLeaving1, 10); // fromJson default
        expect(restored.minutesBeforeLeaving2, 5); // fromJson default
        expect(restored.minutesBeforeArrival, 5); // fromJson default
        expect(restored.activeDaysOfWeek, {1, 2, 3, 4, 5});
      });

      test('fromJson parses activeDaysOfWeek correctly', () {
        final json = settings.toJson();
        json['activeDaysOfWeek'] = [1, 3, 5, 7];

        final restored = AppSettings.fromJson(json);
        expect(restored.activeDaysOfWeek, {1, 3, 5, 7});
      });
    });

    group('copyWith', () {
      test('copies all fields when nothing overridden', () {
        final copy = settings.copyWith();

        expect(copy.wakeUpTime.hour, settings.wakeUpTime.hour);
        expect(copy.wakeUpTime.minute, settings.wakeUpTime.minute);
        expect(copy.leaveHomeTime.hour, settings.leaveHomeTime.hour);
        expect(copy.arrivalDeadline.hour, settings.arrivalDeadline.hour);
        expect(copy.minutesBeforeLeaving1, settings.minutesBeforeLeaving1);
        expect(copy.activeDaysOfWeek, settings.activeDaysOfWeek);
      });

      test('overrides only specified fields', () {
        final copy = settings.copyWith(
          wakeUpTime: const TimeOfDay(hour: 5, minute: 45),
          activeDaysOfWeek: {1, 2, 3},
        );

        expect(copy.wakeUpTime.hour, 5);
        expect(copy.wakeUpTime.minute, 45);
        expect(copy.activeDaysOfWeek, {1, 2, 3});
        // unchanged
        expect(copy.leaveHomeTime.hour, 8);
        expect(copy.arrivalDeadline.hour, 9);
      });
    });

    group('isActiveOnDate', () {
      test('returns true for weekdays with default settings', () {
        // Monday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 23)), true);
        // Tuesday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 24)), true);
        // Wednesday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 25)), true);
        // Thursday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 26)), true);
        // Friday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 27)), true);
      });

      test('returns false for weekends with default settings', () {
        // Saturday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 28)), false);
        // Sunday
        expect(settings.isActiveOnDate(DateTime(2026, 3, 29)), false);
      });

      test('respects custom active days', () {
        final weekendOnly = settings.copyWith(
          activeDaysOfWeek: {6, 7},
        );

        // Monday
        expect(weekendOnly.isActiveOnDate(DateTime(2026, 3, 23)), false);
        // Saturday
        expect(weekendOnly.isActiveOnDate(DateTime(2026, 3, 28)), true);
        // Sunday
        expect(weekendOnly.isActiveOnDate(DateTime(2026, 3, 29)), true);
      });

      test('returns false when no days active', () {
        final noDays = settings.copyWith(activeDaysOfWeek: {});
        expect(noDays.isActiveOnDate(DateTime(2026, 3, 23)), false);
      });

      test('returns true when all days active', () {
        final allDays = settings.copyWith(
          activeDaysOfWeek: {1, 2, 3, 4, 5, 6, 7},
        );
        for (int i = 23; i <= 29; i++) {
          expect(allDays.isActiveOnDate(DateTime(2026, 3, i)), true);
        }
      });
    });
  });
}
