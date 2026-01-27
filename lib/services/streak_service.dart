import '../models/day_record.dart';

class StreakService {
  int calculateCurrentStreak(List<DayRecord> records) {
    if (records.isEmpty) return 0;

    // Sort records by date descending
    final sortedRecords = List<DayRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateTime.now();
    
    // Remove time component for date comparison
    final todayDate = DateTime(today.year, today.month, today.day);
    
    for (final record in sortedRecords) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      final expectedDate = todayDate.subtract(Duration(days: streak));
      
      // If the record date matches the expected date
      if (recordDate.year == expectedDate.year &&
          recordDate.month == expectedDate.month &&
          recordDate.day == expectedDate.day) {
        if (record.wasOnTime) {
          streak++;
        } else {
          break;
        }
      } else if (recordDate.isBefore(expectedDate)) {
        // Gap in records, streak is broken
        break;
      }
    }

    return streak;
  }

  bool shouldCelebrate(int streak) {
    return streak == 3 || streak == 7 || streak == 14 || streak % 30 == 0;
  }

  String getCelebrationMessage(int streak) {
    if (streak == 3) {
      return "Amazing! 3 days in a row! You're building a great habit!";
    } else if (streak == 7) {
      return "Incredible! One week of arriving on time! Keep it up!";
    } else if (streak == 14) {
      return "Outstanding! Two weeks of success! You're a champion!";
    } else if (streak % 30 == 0) {
      return "Phenomenal! ${streak ~/ 30} month${streak ~/ 30 > 1 ? 's' : ''} of consistency! Legendary!";
    }
    return "Great job! Keep the streak going!";
  }

  int getDaysUntilNextReward(int currentStreak, List<int> rewardStreakRequirements) {
    if (rewardStreakRequirements.isEmpty) return 0;
    
    final sortedRequirements = List<int>.from(rewardStreakRequirements)..sort();
    
    for (final requirement in sortedRequirements) {
      if (requirement > currentStreak) {
        return requirement - currentStreak;
      }
    }
    
    return 0;
  }
}
