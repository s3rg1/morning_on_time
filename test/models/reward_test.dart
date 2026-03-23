import 'package:flutter_test/flutter_test.dart';
import 'package:morning_on_time/models/reward.dart';

void main() {
  group('Reward', () {
    late Reward reward;

    setUp(() {
      reward = Reward(
        id: 'test_reward',
        name: 'Ice cream treat',
        requiredStreakLength: 10,
        creationDate: DateTime(2026, 3, 1),
      );
    });

    group('daysRemaining', () {
      test('returns remaining days when streak is less than required', () {
        expect(reward.daysRemaining(0), 10);
        expect(reward.daysRemaining(3), 7);
        expect(reward.daysRemaining(9), 1);
      });

      test('returns 0 when streak equals required', () {
        expect(reward.daysRemaining(10), 0);
      });

      test('returns 0 when streak exceeds required', () {
        expect(reward.daysRemaining(15), 0);
      });
    });

    group('progressPercentage', () {
      test('returns 0 when no streak', () {
        expect(reward.progressPercentage(0), 0.0);
      });

      test('returns 50 at halfway point', () {
        expect(reward.progressPercentage(5), 50.0);
      });

      test('returns 100 when streak equals requirement', () {
        expect(reward.progressPercentage(10), 100.0);
      });

      test('returns 100 when streak exceeds requirement', () {
        expect(reward.progressPercentage(20), 100.0);
      });

      test('calculates fractional percentages', () {
        expect(reward.progressPercentage(3), closeTo(30.0, 0.01));
        expect(reward.progressPercentage(7), closeTo(70.0, 0.01));
      });
    });

    group('isAchieved', () {
      test('returns false when streak is below required', () {
        expect(reward.isAchieved(0), false);
        expect(reward.isAchieved(9), false);
      });

      test('returns true when streak equals required', () {
        expect(reward.isAchieved(10), true);
      });

      test('returns true when streak exceeds required', () {
        expect(reward.isAchieved(15), true);
      });
    });

    group('isHalfway', () {
      test('returns false below halfway', () {
        expect(reward.isHalfway(0), false);
        expect(reward.isHalfway(4), false);
      });

      test('returns true at halfway', () {
        expect(reward.isHalfway(5), true);
      });

      test('returns true between halfway and achieved', () {
        expect(reward.isHalfway(7), true);
      });

      test('returns false when already achieved', () {
        expect(reward.isHalfway(10), false);
        expect(reward.isHalfway(15), false);
      });
    });

    group('isAlmostThere', () {
      test('returns false when more than 1 day remaining', () {
        expect(reward.isAlmostThere(0), false);
        expect(reward.isAlmostThere(5), false);
        expect(reward.isAlmostThere(8), false);
      });

      test('returns true when exactly 1 day remaining', () {
        expect(reward.isAlmostThere(9), true);
      });

      test('returns false when already achieved', () {
        expect(reward.isAlmostThere(10), false);
      });
    });

    group('toJson / fromJson', () {
      test('roundtrips without completionDate', () {
        final json = reward.toJson();
        final restored = Reward.fromJson(json);

        expect(restored.id, 'test_reward');
        expect(restored.name, 'Ice cream treat');
        expect(restored.requiredStreakLength, 10);
        expect(restored.creationDate, DateTime(2026, 3, 1));
        expect(restored.completionDate, isNull);
        expect(restored.isActive, true);
      });

      test('roundtrips with completionDate', () {
        final completed = Reward(
          id: 'done',
          name: 'Movie night',
          requiredStreakLength: 5,
          creationDate: DateTime(2026, 3, 1),
          completionDate: DateTime(2026, 3, 6),
          isActive: false,
        );

        final json = completed.toJson();
        final restored = Reward.fromJson(json);

        expect(restored.completionDate, DateTime(2026, 3, 6));
        expect(restored.isActive, false);
      });

      test('fromJson defaults isActive to true when missing', () {
        final json = {
          'id': 'test',
          'name': 'Test',
          'requiredStreakLength': 5,
          'creationDate': '2026-03-01T00:00:00.000',
        };

        final restored = Reward.fromJson(json);
        expect(restored.isActive, true);
      });
    });

    group('copyWith', () {
      test('copies all fields when nothing overridden', () {
        final copy = reward.copyWith();

        expect(copy.id, reward.id);
        expect(copy.name, reward.name);
        expect(copy.requiredStreakLength, reward.requiredStreakLength);
        expect(copy.creationDate, reward.creationDate);
        expect(copy.isActive, reward.isActive);
      });

      test('overrides only specified fields', () {
        final copy = reward.copyWith(
          name: 'Pizza party',
          isActive: false,
        );

        expect(copy.name, 'Pizza party');
        expect(copy.isActive, false);
        expect(copy.id, 'test_reward'); // unchanged
      });
    });

    group('defaultReward', () {
      test('creates with expected defaults', () {
        final def = Reward.defaultReward();

        expect(def.id, 'default_reward');
        expect(def.requiredStreakLength, 5);
        expect(def.isActive, true);
        expect(def.completionDate, isNull);
      });

      test('accepts custom name', () {
        final def = Reward.defaultReward(name: 'Custom reward');
        expect(def.name, 'Custom reward');
      });

      test('uses fallback name when not provided', () {
        final def = Reward.defaultReward();
        expect(def.name, 'Movie night with popcorn 🍿');
      });
    });
  });
}
