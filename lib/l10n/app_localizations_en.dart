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
  String get arriveBy => 'Arrive by';

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
  String get arrivalConfirmation => 'Arrival Confirmation';

  @override
  String get arrivedOnTime => 'You arrived on time!';

  @override
  String get arrivedLate =>
      'You arrived a bit late, but that\'s okay. Tomorrow is a new opportunity!';

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
}
