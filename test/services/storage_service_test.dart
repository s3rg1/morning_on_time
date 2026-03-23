import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:morning_on_time/services/storage_service.dart';
import 'package:morning_on_time/models/app_settings.dart';
import 'package:morning_on_time/models/day_record.dart';
import 'package:morning_on_time/models/reward.dart';

void main() {
  group('StorageService', () {
    late StorageService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
    });

    group('Settings', () {
      test('loadSettings returns null when nothing stored', () async {
        final result = await storage.loadSettings();
        expect(result, isNull);
      });

      test('saveSettings then loadSettings roundtrips', () async {
        final settings = AppSettings(
          wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
          leaveHomeTime: const TimeOfDay(hour: 8, minute: 0),
          arrivalDeadline: const TimeOfDay(hour: 9, minute: 0),
          minutesBeforeLeaving1: 10,
          activeDaysOfWeek: {1, 2, 3},
        );

        await storage.saveSettings(settings);
        final loaded = await storage.loadSettings();

        expect(loaded, isNotNull);
        expect(loaded!.wakeUpTime.hour, 7);
        expect(loaded.leaveHomeTime.hour, 8);
        expect(loaded.arrivalDeadline.hour, 9);
        expect(loaded.minutesBeforeLeaving1, 10);
        expect(loaded.activeDaysOfWeek, {1, 2, 3});
      });
    });

    group('DayRecords', () {
      test('loadRecords returns empty list when nothing stored', () async {
        final result = await storage.loadRecords();
        expect(result, isEmpty);
      });

      test('saveRecords then loadRecords roundtrips', () async {
        final records = [
          DayRecord(date: DateTime(2026, 3, 23), wasOnTime: true),
          DayRecord(
            date: DateTime(2026, 3, 22),
            wasOnTime: false,
            arrivalTime: DateTime(2026, 3, 22, 9, 15),
          ),
        ];

        await storage.saveRecords(records);
        final loaded = await storage.loadRecords();

        expect(loaded, hasLength(2));
        expect(loaded[0].wasOnTime, true);
        expect(loaded[1].wasOnTime, false);
        expect(loaded[1].arrivalTime, isNotNull);
      });

      test('addRecord appends to existing records', () async {
        final initial = DayRecord(date: DateTime(2026, 3, 22), wasOnTime: true);
        await storage.saveRecords([initial]);

        final newRecord = DayRecord(date: DateTime(2026, 3, 23), wasOnTime: false);
        await storage.addRecord(newRecord);

        final loaded = await storage.loadRecords();
        expect(loaded, hasLength(2));
        expect(loaded[1].wasOnTime, false);
      });
    });

    group('Rewards', () {
      test('loadRewards returns empty list when nothing stored', () async {
        final result = await storage.loadRewards();
        expect(result, isEmpty);
      });

      test('saveRewards then loadRewards roundtrips', () async {
        final rewards = [
          Reward(
            id: 'r1',
            name: 'Ice cream',
            requiredStreakLength: 5,
            creationDate: DateTime(2026, 3, 1),
          ),
        ];

        await storage.saveRewards(rewards);
        final loaded = await storage.loadRewards();

        expect(loaded, hasLength(1));
        expect(loaded[0].id, 'r1');
        expect(loaded[0].name, 'Ice cream');
      });
    });

    group('Streak', () {
      test('getCurrentStreak returns 0 when nothing stored', () async {
        expect(await storage.getCurrentStreak(), 0);
      });

      test('setCurrentStreak then getCurrentStreak roundtrips', () async {
        await storage.setCurrentStreak(7);
        expect(await storage.getCurrentStreak(), 7);
      });
    });

    group('Setup state', () {
      test('isSetupComplete defaults to false', () async {
        expect(await storage.isSetupComplete(), false);
      });

      test('setSetupComplete persists', () async {
        await storage.setSetupComplete(true);
        expect(await storage.isSetupComplete(), true);
      });
    });

    group('Onboarding state', () {
      test('isOnboardingComplete defaults to false', () async {
        expect(await storage.isOnboardingComplete(), false);
      });

      test('setOnboardingComplete persists', () async {
        await storage.setOnboardingComplete(true);
        expect(await storage.isOnboardingComplete(), true);
      });
    });

    group('Journey state', () {
      test('isJourneyActive defaults to false', () async {
        expect(await storage.isJourneyActive(), false);
      });

      test('setJourneyActive true saves start time', () async {
        await storage.setJourneyActive(true);
        expect(await storage.isJourneyActive(), true);
        expect(await storage.getJourneyStartTime(), isNotNull);
      });

      test('setJourneyActive false clears start time', () async {
        await storage.setJourneyActive(true);
        await storage.setJourneyActive(false);
        expect(await storage.isJourneyActive(), false);
        expect(await storage.getJourneyStartTime(), isNull);
      });
    });

    group('Test arrival deadline', () {
      test('getTestArrivalDeadline returns null when nothing stored', () async {
        expect(await storage.getTestArrivalDeadline(), isNull);
      });

      test('setTestArrivalDeadline persists a deadline', () async {
        final deadline = DateTime(2026, 3, 23, 9, 30);
        await storage.setTestArrivalDeadline(deadline);
        final loaded = await storage.getTestArrivalDeadline();
        expect(loaded, deadline);
      });

      test('setTestArrivalDeadline null clears the deadline', () async {
        await storage.setTestArrivalDeadline(DateTime(2026, 3, 23, 9, 30));
        await storage.setTestArrivalDeadline(null);
        expect(await storage.getTestArrivalDeadline(), isNull);
      });
    });

    group('Arrival confirmed', () {
      test('getArrivalConfirmed defaults to false', () async {
        expect(await storage.getArrivalConfirmed(), false);
      });

      test('setArrivalConfirmed persists', () async {
        await storage.setArrivalConfirmed(true);
        expect(await storage.getArrivalConfirmed(), true);
      });
    });

    group('Planned alarms manifest', () {
      test('loadPlannedAlarmsManifest returns empty when nothing stored', () async {
        expect(await storage.loadPlannedAlarmsManifest(), isEmpty);
      });

      test('savePlannedAlarmsManifest then load roundtrips', () async {
        final alarms = [
          {'id': 1, 'type': 'wake_up', 'time': '07:00'},
          {'id': 2, 'type': 'leave', 'time': '08:00'},
        ];

        await storage.savePlannedAlarmsManifest(alarms);
        final loaded = await storage.loadPlannedAlarmsManifest();

        expect(loaded, hasLength(2));
        expect(loaded[0]['type'], 'wake_up');
      });

      test('loadPlannedAlarmsManifestUpdatedAt returns timestamp', () async {
        await storage.savePlannedAlarmsManifest([{'id': 1}]);
        final updatedAt = await storage.loadPlannedAlarmsManifestUpdatedAt();
        expect(updatedAt, isNotNull);
      });
    });

    group('clearAll', () {
      test('clears all stored data', () async {
        await storage.setSetupComplete(true);
        await storage.setCurrentStreak(5);
        await storage.setOnboardingComplete(true);

        await storage.clearAll();

        expect(await storage.isSetupComplete(), false);
        expect(await storage.getCurrentStreak(), 0);
        expect(await storage.isOnboardingComplete(), false);
      });
    });
  });
}
