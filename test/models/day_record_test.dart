import 'package:flutter_test/flutter_test.dart';
import 'package:morning_on_time/models/day_record.dart';

void main() {
  group('DayRecord', () {
    group('constructor', () {
      test('creates record with required fields', () {
        final record = DayRecord(
          date: DateTime(2026, 3, 23),
          wasOnTime: true,
        );

        expect(record.date, DateTime(2026, 3, 23));
        expect(record.wasOnTime, true);
        expect(record.arrivalTime, isNull);
      });

      test('creates record with arrivalTime', () {
        final arrival = DateTime(2026, 3, 23, 8, 45);
        final record = DayRecord(
          date: DateTime(2026, 3, 23),
          wasOnTime: true,
          arrivalTime: arrival,
        );

        expect(record.arrivalTime, arrival);
      });
    });

    group('toJson / fromJson', () {
      test('roundtrips without arrivalTime', () {
        final record = DayRecord(
          date: DateTime(2026, 3, 23),
          wasOnTime: false,
        );

        final json = record.toJson();
        final restored = DayRecord.fromJson(json);

        expect(restored.date, record.date);
        expect(restored.wasOnTime, false);
        expect(restored.arrivalTime, isNull);
      });

      test('roundtrips with arrivalTime', () {
        final arrival = DateTime(2026, 3, 23, 8, 45, 30);
        final record = DayRecord(
          date: DateTime(2026, 3, 23),
          wasOnTime: true,
          arrivalTime: arrival,
        );

        final json = record.toJson();
        final restored = DayRecord.fromJson(json);

        expect(restored.date, record.date);
        expect(restored.wasOnTime, true);
        expect(restored.arrivalTime, arrival);
      });

      test('toJson produces expected keys', () {
        final record = DayRecord(
          date: DateTime(2026, 3, 23),
          wasOnTime: true,
          arrivalTime: DateTime(2026, 3, 23, 8, 45),
        );

        final json = record.toJson();

        expect(json['date'], isA<String>());
        expect(json['wasOnTime'], true);
        expect(json['arrivalTime'], isA<String>());
      });

      test('fromJson handles null arrivalTime', () {
        final json = {
          'date': '2026-03-23T00:00:00.000',
          'wasOnTime': false,
          'arrivalTime': null,
        };

        final record = DayRecord.fromJson(json);

        expect(record.wasOnTime, false);
        expect(record.arrivalTime, isNull);
      });
    });
  });
}
