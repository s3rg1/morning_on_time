import 'package:flutter_test/flutter_test.dart';
import 'package:morning_on_time/models/day_record.dart';
import 'package:morning_on_time/services/streak_service.dart';

void main() {
  group('StreakService', () {
    late StreakService service;

    setUp(() {
      service = StreakService();
    });

    group('calculateCurrentStreak', () {
      test('returns 0 for empty records', () {
        expect(service.calculateCurrentStreak([]), 0);
      });

      test('returns 1 for a single on-time record', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
        ];
        expect(service.calculateCurrentStreak(records), 1);
      });

      test('returns 0 for a single not-on-time record', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: false),
        ];
        expect(service.calculateCurrentStreak(records), 0);
      });

      test('counts consecutive on-time records from most recent', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 20), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 21), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 22), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
        ];
        expect(service.calculateCurrentStreak(records), 4);
      });

      test('stops counting when a not-on-time record is found', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 20), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 21), wasOnTime: false),
          DayRecord(date: DateTime(2026, 3, 22), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
        ];
        expect(service.calculateCurrentStreak(records), 2);
      });

      test('returns 0 when most recent record is not on time', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 20), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 21), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: false),
        ];
        expect(service.calculateCurrentStreak(records), 0);
      });

      test('handles unsorted records correctly', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 20), wasOnTime: false),
          DayRecord(date: DateTime(2026, 3, 22), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 21), wasOnTime: true),
        ];
        // Most recent first: 23(T), 22(T), 21(T), 20(F) → streak = 3
        expect(service.calculateCurrentStreak(records), 3);
      });

      test('ignores gaps in dates (only breaks on wasOnTime=false)', () {
        final records = [
          DayRecord(date: DateTime(2026, 3, 10), wasOnTime: true),
          // gap: 11–19 missing
          DayRecord(date: DateTime(2026, 3, 20), wasOnTime: true),
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
        ];
        expect(service.calculateCurrentStreak(records), 3);
      });
    });

    group('shouldCelebrate', () {
      test('returns true for milestone streaks', () {
        expect(service.shouldCelebrate(3), true);
        expect(service.shouldCelebrate(7), true);
        expect(service.shouldCelebrate(14), true);
        expect(service.shouldCelebrate(30), true);
        expect(service.shouldCelebrate(60), true);
        expect(service.shouldCelebrate(90), true);
      });

      test('returns true for streak 0 (edge case: 0 % 30 == 0)', () {
        expect(service.shouldCelebrate(0), true);
      });

      test('returns false for non-milestone streaks', () {
        expect(service.shouldCelebrate(1), false);
        expect(service.shouldCelebrate(2), false);
        expect(service.shouldCelebrate(4), false);
        expect(service.shouldCelebrate(5), false);
        expect(service.shouldCelebrate(10), false);
        expect(service.shouldCelebrate(15), false);
        expect(service.shouldCelebrate(29), false);
      });
    });

    group('getCelebrationMessage', () {
      test('returns specific message for 3-day streak', () {
        final msg = service.getCelebrationMessage(3);
        expect(msg, contains('3 days'));
      });

      test('returns specific message for 7-day streak', () {
        final msg = service.getCelebrationMessage(7);
        expect(msg, contains('week'));
      });

      test('returns specific message for 14-day streak', () {
        final msg = service.getCelebrationMessage(14);
        expect(msg, contains('Two weeks'));
      });

      test('returns monthly message for 30-day multiples', () {
        expect(service.getCelebrationMessage(30), contains('1 month'));
        expect(service.getCelebrationMessage(60), contains('2 months'));
        expect(service.getCelebrationMessage(90), contains('3 months'));
      });

      test('returns generic message for non-milestone streaks', () {
        final msg = service.getCelebrationMessage(5);
        expect(msg, contains('Keep the streak going'));
      });
    });

    group('getDaysUntilNextReward', () {
      test('returns 0 for empty requirements', () {
        expect(service.getDaysUntilNextReward(5, []), 0);
      });

      test('returns days until next requirement', () {
        expect(service.getDaysUntilNextReward(3, [5, 10, 15]), 2);
        expect(service.getDaysUntilNextReward(0, [5, 10, 15]), 5);
        expect(service.getDaysUntilNextReward(7, [5, 10, 15]), 3);
      });

      test('returns 0 when current streak exceeds all requirements', () {
        expect(service.getDaysUntilNextReward(20, [5, 10, 15]), 0);
      });

      test('returns 0 when current streak equals highest requirement', () {
        expect(service.getDaysUntilNextReward(15, [5, 10, 15]), 0);
      });

      test('handles unsorted requirements', () {
        expect(service.getDaysUntilNextReward(3, [15, 5, 10]), 2);
      });

      test('handles single requirement', () {
        expect(service.getDaysUntilNextReward(3, [7]), 4);
        expect(service.getDaysUntilNextReward(7, [7]), 0);
      });
    });
  });
}
