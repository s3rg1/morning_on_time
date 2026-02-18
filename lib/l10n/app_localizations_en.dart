// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Morning Mission';

  @override
  String get todaysMission => 'Today\'s Mission';

  @override
  String get arriveOnTime => 'Arrive at school on time!';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Days Streak',
      one: 'Day Streak',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => '🌅 Good Morning!';

  @override
  String get missionMessage =>
      'Today\'s mission is to arrive at school on time. Let\'s go!';

  @override
  String get quickCheckIn => '⏰ Quick Check-In';

  @override
  String get howAreThings => 'How are things going this morning?';

  @override
  String get goingWell => 'Going Well';

  @override
  String get runningTight => 'Running Tight';

  @override
  String get leaveHomeSoon => '🏃 Leave Home Soon!';

  @override
  String get leaveHomeSoonMessage =>
      'In five minutes we must leave home, hurry up!!';

  @override
  String get leaveHomeNow => '🚪 Leave Home Now!';

  @override
  String get leaveHomeNowMessage => 'We leave home now or we\'ll be late.';

  @override
  String get openAppToSeeCountdown => 'Open app to see countdown timer.';

  @override
  String get arrivalCheck => '🎯 Have we arrived on time?';

  @override
  String get arrivalCheckMessage => 'Tap to confirm your arrival status';

  @override
  String get yesWeHave => 'Yes, we have';

  @override
  String get noWeHavent => 'No, we haven\'t';

  @override
  String get arrivedAtSchool => 'Arrived at School';

  @override
  String get wakeUp => 'Wake up';

  @override
  String get leaveHome => 'Leave home';

  @override
  String get arriveBy => 'Arrive by:';

  @override
  String get todaysSchedule => 'Today\'s Schedule';

  @override
  String get monthlyView => 'Monthly View';

  @override
  String get rewards => 'Rewards';

  @override
  String get greatJob => 'Great job! You arrived on time today!';

  @override
  String get didntMakeIt => 'We didn\'t make it today. Tomorrow is a new day!';

  @override
  String get keepUpGreatWork => 'Keep up the great work!';

  @override
  String get tryAgainTomorrow => 'Try again tomorrow!';

  @override
  String get arrivalConfirmation => 'Arrival Confirmation';

  @override
  String get arrivedOnTime => 'You arrived on time!';

  @override
  String get arrivedLate =>
      'You arrived a bit late, but that\'s okay. Tomorrow is a new opportunity!';

  @override
  String get arrivalTime => 'Arrival time:';

  @override
  String get confirm => 'Confirm';

  @override
  String get setupMorningRoutine => 'Set Up Your Morning Routine';

  @override
  String get setupDescription =>
      'Let\'s plan your morning to help you arrive at school on time!';

  @override
  String get wakeUpTime => 'Wake-up Time';

  @override
  String get leaveHomeTime => 'Leave Home Time';

  @override
  String get latestArrivalTime => 'Latest Arrival Time';

  @override
  String get startTheJourney => 'Save Plan';

  @override
  String get settingUpRoutine => 'Setting up your morning routine...';

  @override
  String get routineSaved => '✅ Morning routine saved successfully!';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get onTime => 'On Time';

  @override
  String get late => 'Late';

  @override
  String get noData => 'No data';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get hurryCritical => 'HURRY! Almost there!';

  @override
  String get hurryUp => 'Hurry up!';

  @override
  String get onTrack => 'On track!';

  @override
  String get journeyInProgress => 'Journey in Progress';

  @override
  String get onboardingProblemHeadline => 'Are mornings a daily struggle?';

  @override
  String get onboardingProblemPoint1 =>
      'Arriving late to school despite your best efforts?';

  @override
  String get onboardingProblemPoint2 =>
      'Mornings filled with chaos, constant reminders, and stress?';

  @override
  String get onboardingProblemPoint3 =>
      'Children lacking a sense of urgency while you\'re running behind?';

  @override
  String get onboardingSolutionHeadline => 'Turn mornings into a mission';

  @override
  String get onboardingSolutionPoint1 =>
      'Morning Mission helps your family arrive on time consistently';

  @override
  String get onboardingSolutionPoint2 =>
      'Voice-driven reminders at key moments—no screens, no checklists';

  @override
  String get onboardingSolutionPoint3 =>
      'Motivates with streaks and rewards, not guilt or pressure';

  @override
  String get onboardingSolutionPoint4 =>
      'The app activates itself. You just live your morning.';

  @override
  String get onboardingHowItWorksHeadline =>
      'Automatic support throughout the morning';

  @override
  String get onboardingHowItWorksPoint1 =>
      'Wake-up message sets today\'s mission';

  @override
  String get onboardingHowItWorksPoint2 =>
      'Voice check-ins every 10 minutes to stay on track';

  @override
  String get onboardingHowItWorksPoint3 => 'Countdown when it\'s time to leave';

  @override
  String get onboardingHowItWorksPoint4 =>
      'Confirm arrival to celebrate success and build your streak!';

  @override
  String get onboardingPermissionsHeadline =>
      'Two quick permissions to get started';

  @override
  String get onboardingPermissionsIntro =>
      'For the app to work reliably, we need:';

  @override
  String get onboardingPermissionNotifications => '📬 Notifications';

  @override
  String get onboardingPermissionNotificationsDesc =>
      'To send voice reminders and time alerts throughout your morning';

  @override
  String get onboardingPermissionBattery => '🔋 Battery Unrestricted';

  @override
  String get onboardingPermissionBatteryDesc =>
      'To ensure alarms fire on time even when your phone is locked or sleeping';

  @override
  String get onboardingPermissionExplanation =>
      'Why battery permission matters: Android puts apps to sleep to save power. Without this permission, morning alarms might not wake up on time when you need them most.';

  @override
  String get onboardingGrantPermissions => 'Grant Permissions & Continue';

  @override
  String get onboardingPermissionsRequired => 'Permissions Required';

  @override
  String get onboardingPermissionsRequiredMessage =>
      'Morning Mission needs both permissions to work reliably. Without them, alarms may not fire when your family needs them most.\n\nPlease grant both Notifications and Battery Unrestricted permissions to continue.';

  @override
  String get onboardingExitApp => 'Exit App';

  @override
  String get onboardingTryAgain => 'Try Again';

  @override
  String get onboardingError => 'Error';

  @override
  String onboardingErrorMessage(String error) {
    return 'An error occurred while requesting permissions:\n\n$error';
  }

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get lowVolume => 'Low Volume';

  @override
  String lowVolumeMessage(int volume) {
    return 'Your media volume is at $volume%.\n\nConsider increasing it to hear morning voice messages.';
  }

  @override
  String get okIllAdjustIt => 'OK, I\'ll adjust it';

  @override
  String get streakLevelBeginner => 'Beginner Runner';

  @override
  String get streakLevelOccasional => 'Occasional Runner';

  @override
  String get streakLevelPro => 'Pro Runner';

  @override
  String get streakLevelChampion => 'Champion Runner';

  @override
  String get streakLevelUltimate => 'Ultimate Jaguar';

  @override
  String get testAllAlarms => '🧪 Test All Alarms (22-Minute Journey)';

  @override
  String get testAllAlarmsDescription =>
      'This will test ALL alarm types in ~22 minutes:';

  @override
  String get testAllAlarmsDetails =>
      '✅ Wake-up alarm (T+2 min)\n✅ Checkpoint alarm #1 (T+12 min)\n✅ Leave Home Soon (T+13 min)\n✅ Leave Home → countdown starts (T+18 min)\n✅ Pre-Arrival Check (T+20 min)\n✅ Arrival deadline (T+22 min)\n\nTap \"Arrived\" before deadline to test success path.\nLet timer expire to test failure path.\n\n⚠️ Cannot run between 11:38 PM - midnight.';

  @override
  String get startTest => '🚀 Start Test';

  @override
  String get cannotScheduleNotifications =>
      '❌ Cannot schedule notifications - permission not granted!';

  @override
  String get testNotificationSuccess =>
      '✅ Showing test NOW! Scheduled test in 30s. KEEP APP OPEN and watch for it!';

  @override
  String errorWithDetails(String error) {
    return '❌ Error: $error';
  }

  @override
  String testCannotRunMidnight(int minutes) {
    return '❌ Test cannot run - too close to midnight!\nOnly $minutes minutes until midnight.\nTest needs 22 minutes. Please try earlier in the day.';
  }

  @override
  String get testStarted =>
      '🧪 Test Started! (22-minute journey)\n• Wake-up: in 2 minutes\n• Checkpoint #1: in 12 minutes (NEW!)\n• Leave Home Soon: in 13 minutes\n• Leave Home: in 18 minutes → countdown starts\n• Pre-Arrival Check: in 20 minutes\n• Arrival deadline: in 22 minutes\n• Stay on screen to observe alarms firing';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get activeDays => '📅 Active Days';

  @override
  String get weekdaysOnly => 'Weekdays Only';

  @override
  String get everyDay => 'Every Day';

  @override
  String get viewScheduledAlarms => 'View Scheduled Alarms (Testing)';

  @override
  String get totalDays => 'Total Days';

  @override
  String get noDataForMonth => 'No data for this month';

  @override
  String get legend => 'Legend:';

  @override
  String get onTimeArrival => 'On time arrival';

  @override
  String get lateArrival => 'Late arrival';

  @override
  String get noRecord => 'No record';

  @override
  String get manageReward => 'Manage Reward';

  @override
  String get rewardName => 'Reward Name';

  @override
  String get rewardNameHint => 'e.g., Pizza night 🍕';

  @override
  String get quickSuggestions => 'Quick Suggestions';

  @override
  String get streakGoal => 'Streak Goal';

  @override
  String get days => 'days';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get currentProgress => 'Current Progress:';

  @override
  String daysProgress(int current, int total) {
    return '$current out of $total days';
  }

  @override
  String get keepItUp => 'Keep it up!';

  @override
  String get notStartedYet => 'Not started yet';

  @override
  String get pleaseEnterRewardName => 'Please enter a reward name';

  @override
  String rewardUpdated(String name) {
    return 'Reward updated: $name';
  }

  @override
  String errorSavingReward(String error) {
    return 'Error saving reward: $error';
  }

  @override
  String get rewardMovieNight => 'Movie night';

  @override
  String get rewardPizzaDinner => 'Pizza dinner';

  @override
  String get rewardExtraGameTime => 'Extra game time';

  @override
  String get rewardParkVisit => 'Park visit';

  @override
  String get rewardArtProject => 'Art project';

  @override
  String get rewardIceCreamOuting => 'Ice cream outing';

  @override
  String get defaultRewardName => 'Movie night with popcorn 🍿';

  @override
  String get splashTitle => 'Morning Mission';

  @override
  String get splashSubtitle => 'Win the morning';

  @override
  String get rewardGoal => '🎁 Reward Goal';

  @override
  String get todaysMissionArriveOnTime => 'Today\'s Mission: Arrive on time!';

  @override
  String get tomorrowsMissionArriveOnTime =>
      'Tomorrow\'s Mission: Arrive on time!';

  @override
  String missionForDateArriveOnTime(String date) {
    return '$date Mission: Arrive on time!';
  }

  @override
  String get manage => 'Manage';

  @override
  String rewardCongratulations(String rewardName) {
    return '🎉 Congratulations! You earned $rewardName';
  }

  @override
  String rewardAlmostThere(String rewardName) {
    return 'Almost there! 🚀 1 day to earn $rewardName';
  }

  @override
  String rewardHalfway(int days, String rewardName) {
    return 'Halfway there! 🔥 $days days to earn $rewardName';
  }

  @override
  String rewardDaysRemaining(int days, String daysWord, String rewardName) {
    return 'Only $days $daysWord to earn $rewardName';
  }

  @override
  String get day => 'day';

  @override
  String get motivationYouveGotThis => 'You\'ve got this!';

  @override
  String get motivationLetsDoThis => 'Let\'s do this!';

  @override
  String get motivationReadyToSucceed => 'Ready to succeed!';

  @override
  String get motivationTimeToShine => 'Time to shine!';

  @override
  String get motivationYouCanDoIt => 'You can do it!';

  @override
  String get wakeUpAt => 'Wake up at:';

  @override
  String get leaveAt => 'Leave at:';

  @override
  String daysUntilNextLevel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days until next level! 🚀',
      one: '1 day until next level! 🎉',
    );
    return '$_temp0';
  }
}
