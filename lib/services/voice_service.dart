import 'package:flutter/services.dart';
import '../models/check_in_status.dart';

class VoiceService {
  static const platform = MethodChannel('com.morningontime/tts');

  Future<void> speak(String message) async {
    try {
      // On Android/iOS, we'll use flutter_tts package, but for simplicity
      // we're just logging for now. In production, integrate flutter_tts.
      print('🔊 Voice: $message');
      // await platform.invokeMethod('speak', {'message': message});
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  Future<void> playWakeUpMessage() async {
    await speak("Good morning! Today's mission is to arrive at school on time. Let's go!");
  }

  Future<void> playTimeToLeaveMessage(int minutes, CheckInStatus status) async {
    String message;
    // Simplified: single voice message for all statuses
    if (minutes <= 2) {
      message = "Time to leave in $minutes minutes. Let's go!";
    } else {
      message = "We have $minutes minutes before leaving. You're doing great!";
    }
    await speak(message);
  }

  Future<void> playSuccessMessage(int streak) async {
    String message;
    if (streak == 1) {
      message = "Yes! We made it on time! Great start!";
    } else if (streak == 3) {
      message = "Amazing! 3 days in a row! You're building a great habit!";
    } else if (streak == 7) {
      message = "Incredible! One week of arriving on time! Keep it up!";
    } else if (streak == 14) {
      message = "Outstanding! Two weeks of success! You're a champion!";
    } else {
      message = "Yes! Another day achieved. That's a $streak-day streak!";
    }
    await speak(message);
  }

  Future<void> playFailureMessage() async {
    await speak("We didn't make it today. Tomorrow we try again.");
  }

  Future<void> playRewardMessage(String rewardName, int daysRemaining) async {
    String message;
    if (daysRemaining == 0) {
      message = "Congratulations! You've earned: $rewardName!";
    } else if (daysRemaining == 1) {
      message = "Only 1 more day to earn $rewardName!";
    } else {
      message = "Only $daysRemaining more days to earn $rewardName!";
    }
    await speak(message);
  }

  Future<void> playCountdownMessage(int minutes) async {
    if (minutes <= 3) {
      await speak("If we arrive in the next $minutes minutes, we keep the streak alive!");
    }
  }
}
