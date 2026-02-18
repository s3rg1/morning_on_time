import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Morning Mission'**
  String get appTitle;

  /// Title for today's mission section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Mission'**
  String get todaysMission;

  /// Mission description
  ///
  /// In en, this message translates to:
  /// **'Arrive at school on time!'**
  String get arriveOnTime;

  /// Streak counter label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Day Streak} other{Days Streak}}'**
  String daysStreak(int count);

  /// Morning notification title
  ///
  /// In en, this message translates to:
  /// **'🌅 Good Morning!'**
  String get goodMorning;

  /// Morning notification message
  ///
  /// In en, this message translates to:
  /// **'Today\'s mission is to arrive at school on time. Let\'s go!'**
  String get missionMessage;

  /// Check-in notification title
  ///
  /// In en, this message translates to:
  /// **'⏰ Quick Check-In'**
  String get quickCheckIn;

  /// Check-in notification message
  ///
  /// In en, this message translates to:
  /// **'How are things going this morning?'**
  String get howAreThings;

  /// Status button - things are going well
  ///
  /// In en, this message translates to:
  /// **'Going Well'**
  String get goingWell;

  /// Status button - running behind schedule
  ///
  /// In en, this message translates to:
  /// **'Running Tight'**
  String get runningTight;

  /// Leave home soon notification title
  ///
  /// In en, this message translates to:
  /// **'🏃 Leave Home Soon!'**
  String get leaveHomeSoon;

  /// Leave home soon notification message
  ///
  /// In en, this message translates to:
  /// **'In five minutes we must leave home, hurry up!!'**
  String get leaveHomeSoonMessage;

  /// Leave home now notification title
  ///
  /// In en, this message translates to:
  /// **'🚪 Leave Home Now!'**
  String get leaveHomeNow;

  /// Leave home now notification message
  ///
  /// In en, this message translates to:
  /// **'We leave home now or we\'ll be late.'**
  String get leaveHomeNowMessage;

  /// Additional text for leave home now notification
  ///
  /// In en, this message translates to:
  /// **'Open app to see countdown timer.'**
  String get openAppToSeeCountdown;

  /// Arrival check notification title
  ///
  /// In en, this message translates to:
  /// **'🎯 Have we arrived on time?'**
  String get arrivalCheck;

  /// Arrival check notification message
  ///
  /// In en, this message translates to:
  /// **'Tap to confirm your arrival status'**
  String get arrivalCheckMessage;

  /// Arrived on time confirmation button
  ///
  /// In en, this message translates to:
  /// **'Yes, we have'**
  String get yesWeHave;

  /// Did not arrive on time button
  ///
  /// In en, this message translates to:
  /// **'No, we haven\'t'**
  String get noWeHavent;

  /// Button to confirm arrival
  ///
  /// In en, this message translates to:
  /// **'Arrived at School'**
  String get arrivedAtSchool;

  /// Wake up time label
  ///
  /// In en, this message translates to:
  /// **'Wake up'**
  String get wakeUp;

  /// Leave home time label
  ///
  /// In en, this message translates to:
  /// **'Leave home'**
  String get leaveHome;

  /// Arrival time label in mission frame
  ///
  /// In en, this message translates to:
  /// **'Arrive by:'**
  String get arriveBy;

  /// Schedule section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaysSchedule;

  /// Monthly view button
  ///
  /// In en, this message translates to:
  /// **'Monthly View'**
  String get monthlyView;

  /// Rewards button
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// Success message for on-time arrival
  ///
  /// In en, this message translates to:
  /// **'Great job! You arrived on time today!'**
  String get greatJob;

  /// Message for late arrival
  ///
  /// In en, this message translates to:
  /// **'We didn\'t make it today. Tomorrow is a new day!'**
  String get didntMakeIt;

  /// Encouragement message for on-time arrival
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get keepUpGreatWork;

  /// Encouragement message for late arrival
  ///
  /// In en, this message translates to:
  /// **'Try again tomorrow!'**
  String get tryAgainTomorrow;

  /// Arrival dialog title
  ///
  /// In en, this message translates to:
  /// **'Arrival Confirmation'**
  String get arrivalConfirmation;

  /// On-time arrival message
  ///
  /// In en, this message translates to:
  /// **'You arrived on time!'**
  String get arrivedOnTime;

  /// Late arrival message
  ///
  /// In en, this message translates to:
  /// **'You arrived a bit late, but that\'s okay. Tomorrow is a new opportunity!'**
  String get arrivedLate;

  /// Label for arrival time in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Arrival time:'**
  String get arrivalTime;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Setup screen title
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Morning Routine'**
  String get setupMorningRoutine;

  /// Setup screen description
  ///
  /// In en, this message translates to:
  /// **'Let\'s plan your morning to help you arrive at school on time!'**
  String get setupDescription;

  /// Wake-up time input label
  ///
  /// In en, this message translates to:
  /// **'Wake-up Time'**
  String get wakeUpTime;

  /// Leave home time input label
  ///
  /// In en, this message translates to:
  /// **'Leave Home Time'**
  String get leaveHomeTime;

  /// Arrival deadline input label
  ///
  /// In en, this message translates to:
  /// **'Latest Arrival Time'**
  String get latestArrivalTime;

  /// Save button on setup screen
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get startTheJourney;

  /// Loading message when saving settings
  ///
  /// In en, this message translates to:
  /// **'Setting up your morning routine...'**
  String get settingUpRoutine;

  /// Success message after saving settings
  ///
  /// In en, this message translates to:
  /// **'✅ Morning routine saved successfully!'**
  String get routineSaved;

  /// Error message when saving fails
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String errorSavingSettings(String error);

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// On time status
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// Late status
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No data available
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Countdown timer label
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Critical urgency message (2 minutes or less)
  ///
  /// In en, this message translates to:
  /// **'HURRY! Almost there!'**
  String get hurryCritical;

  /// Urgency message (5 minutes or less)
  ///
  /// In en, this message translates to:
  /// **'Hurry up!'**
  String get hurryUp;

  /// On schedule message
  ///
  /// In en, this message translates to:
  /// **'On track!'**
  String get onTrack;

  /// Journey active title
  ///
  /// In en, this message translates to:
  /// **'Journey in Progress'**
  String get journeyInProgress;

  /// Onboarding screen 1 headline
  ///
  /// In en, this message translates to:
  /// **'Are mornings a daily struggle?'**
  String get onboardingProblemHeadline;

  /// Onboarding screen 1 problem point 1
  ///
  /// In en, this message translates to:
  /// **'Arriving late to school despite your best efforts?'**
  String get onboardingProblemPoint1;

  /// Onboarding screen 1 problem point 2
  ///
  /// In en, this message translates to:
  /// **'Mornings filled with chaos, constant reminders, and stress?'**
  String get onboardingProblemPoint2;

  /// Onboarding screen 1 problem point 3
  ///
  /// In en, this message translates to:
  /// **'Children lacking a sense of urgency while you\'re running behind?'**
  String get onboardingProblemPoint3;

  /// Onboarding screen 2 headline
  ///
  /// In en, this message translates to:
  /// **'Turn mornings into a mission'**
  String get onboardingSolutionHeadline;

  /// Onboarding screen 2 solution point 1
  ///
  /// In en, this message translates to:
  /// **'Morning Mission helps your family arrive on time consistently'**
  String get onboardingSolutionPoint1;

  /// Onboarding screen 2 solution point 2
  ///
  /// In en, this message translates to:
  /// **'Voice-driven reminders at key moments—no screens, no checklists'**
  String get onboardingSolutionPoint2;

  /// Onboarding screen 2 solution point 3
  ///
  /// In en, this message translates to:
  /// **'Motivates with streaks and rewards, not guilt or pressure'**
  String get onboardingSolutionPoint3;

  /// Onboarding screen 2 solution point 4
  ///
  /// In en, this message translates to:
  /// **'The app activates itself. You just live your morning.'**
  String get onboardingSolutionPoint4;

  /// Onboarding screen 3 headline
  ///
  /// In en, this message translates to:
  /// **'Automatic support throughout the morning'**
  String get onboardingHowItWorksHeadline;

  /// Onboarding screen 3 step 1
  ///
  /// In en, this message translates to:
  /// **'Wake-up message sets today\'s mission'**
  String get onboardingHowItWorksPoint1;

  /// Onboarding screen 3 step 2
  ///
  /// In en, this message translates to:
  /// **'Voice check-ins every 10 minutes to stay on track'**
  String get onboardingHowItWorksPoint2;

  /// Onboarding screen 3 step 3
  ///
  /// In en, this message translates to:
  /// **'Countdown when it\'s time to leave'**
  String get onboardingHowItWorksPoint3;

  /// Onboarding screen 3 step 4
  ///
  /// In en, this message translates to:
  /// **'Confirm arrival to celebrate success and build your streak!'**
  String get onboardingHowItWorksPoint4;

  /// Onboarding screen 4 headline
  ///
  /// In en, this message translates to:
  /// **'Two quick permissions to get started'**
  String get onboardingPermissionsHeadline;

  /// Onboarding screen 4 intro text
  ///
  /// In en, this message translates to:
  /// **'For the app to work reliably, we need:'**
  String get onboardingPermissionsIntro;

  /// Notifications permission title
  ///
  /// In en, this message translates to:
  /// **'📬 Notifications'**
  String get onboardingPermissionNotifications;

  /// Notifications permission description
  ///
  /// In en, this message translates to:
  /// **'To send voice reminders and time alerts throughout your morning'**
  String get onboardingPermissionNotificationsDesc;

  /// Battery permission title
  ///
  /// In en, this message translates to:
  /// **'🔋 Battery Unrestricted'**
  String get onboardingPermissionBattery;

  /// Battery permission description
  ///
  /// In en, this message translates to:
  /// **'To ensure alarms fire on time even when your phone is locked or sleeping'**
  String get onboardingPermissionBatteryDesc;

  /// Battery permission explanation box
  ///
  /// In en, this message translates to:
  /// **'Why battery permission matters: Android puts apps to sleep to save power. Without this permission, morning alarms might not wake up on time when you need them most.'**
  String get onboardingPermissionExplanation;

  /// Button to grant permissions
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions & Continue'**
  String get onboardingGrantPermissions;

  /// Permissions denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get onboardingPermissionsRequired;

  /// Permissions denied dialog message
  ///
  /// In en, this message translates to:
  /// **'Morning Mission needs both permissions to work reliably. Without them, alarms may not fire when your family needs them most.\n\nPlease grant both Notifications and Battery Unrestricted permissions to continue.'**
  String get onboardingPermissionsRequiredMessage;

  /// Exit app button
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get onboardingExitApp;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get onboardingTryAgain;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get onboardingError;

  /// Error dialog message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while requesting permissions:\n\n{error}'**
  String onboardingErrorMessage(String error);

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Low volume warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Low Volume'**
  String get lowVolume;

  /// Low volume warning message
  ///
  /// In en, this message translates to:
  /// **'Your media volume is at {volume}%.\n\nConsider increasing it to hear morning voice messages.'**
  String lowVolumeMessage(int volume);

  /// Volume adjustment acknowledgment button
  ///
  /// In en, this message translates to:
  /// **'OK, I\'ll adjust it'**
  String get okIllAdjustIt;

  /// Streak level 0-9 days
  ///
  /// In en, this message translates to:
  /// **'Beginner Runner'**
  String get streakLevelBeginner;

  /// Streak level 10-19 days
  ///
  /// In en, this message translates to:
  /// **'Occasional Runner'**
  String get streakLevelOccasional;

  /// Streak level 20-29 days
  ///
  /// In en, this message translates to:
  /// **'Pro Runner'**
  String get streakLevelPro;

  /// Streak level 30-39 days
  ///
  /// In en, this message translates to:
  /// **'Champion Runner'**
  String get streakLevelChampion;

  /// Streak level 40+ days
  ///
  /// In en, this message translates to:
  /// **'Ultimate Jaguar'**
  String get streakLevelUltimate;

  /// Test menu dialog title
  ///
  /// In en, this message translates to:
  /// **'🧪 Test All Alarms (22-Minute Journey)'**
  String get testAllAlarms;

  /// Test menu description header
  ///
  /// In en, this message translates to:
  /// **'This will test ALL alarm types in ~22 minutes:'**
  String get testAllAlarmsDescription;

  /// Test menu detailed timeline
  ///
  /// In en, this message translates to:
  /// **'✅ Wake-up alarm (T+2 min)\n✅ Checkpoint alarm #1 (T+12 min)\n✅ Leave Home Soon (T+13 min)\n✅ Leave Home → countdown starts (T+18 min)\n✅ Pre-Arrival Check (T+20 min)\n✅ Arrival deadline (T+22 min)\n\nTap \"Arrived\" before deadline to test success path.\nLet timer expire to test failure path.\n\n⚠️ Cannot run between 11:38 PM - midnight.'**
  String get testAllAlarmsDetails;

  /// Start test button
  ///
  /// In en, this message translates to:
  /// **'🚀 Start Test'**
  String get startTest;

  /// Error message when notification permission missing
  ///
  /// In en, this message translates to:
  /// **'❌ Cannot schedule notifications - permission not granted!'**
  String get cannotScheduleNotifications;

  /// Test notification scheduled successfully
  ///
  /// In en, this message translates to:
  /// **'✅ Showing test NOW! Scheduled test in 30s. KEEP APP OPEN and watch for it!'**
  String get testNotificationSuccess;

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'❌ Error: {error}'**
  String errorWithDetails(String error);

  /// Error when test crosses midnight
  ///
  /// In en, this message translates to:
  /// **'❌ Test cannot run - too close to midnight!\nOnly {minutes} minutes until midnight.\nTest needs 22 minutes. Please try earlier in the day.'**
  String testCannotRunMidnight(int minutes);

  /// Test started success message with timeline
  ///
  /// In en, this message translates to:
  /// **'🧪 Test Started! (22-minute journey)\n• Wake-up: in 2 minutes\n• Checkpoint #1: in 12 minutes (NEW!)\n• Leave Home Soon: in 13 minutes\n• Leave Home: in 18 minutes → countdown starts\n• Pre-Arrival Check: in 20 minutes\n• Arrival deadline: in 22 minutes\n• Stay on screen to observe alarms firing'**
  String get testStarted;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Active days section header
  ///
  /// In en, this message translates to:
  /// **'📅 Active Days'**
  String get activeDays;

  /// Weekdays preset button
  ///
  /// In en, this message translates to:
  /// **'Weekdays Only'**
  String get weekdaysOnly;

  /// Every day preset button
  ///
  /// In en, this message translates to:
  /// **'Every Day'**
  String get everyDay;

  /// Debug button to view alarms
  ///
  /// In en, this message translates to:
  /// **'View Scheduled Alarms (Testing)'**
  String get viewScheduledAlarms;

  /// Total days in month label
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// Empty state message for monthly view
  ///
  /// In en, this message translates to:
  /// **'No data for this month'**
  String get noDataForMonth;

  /// Calendar legend header
  ///
  /// In en, this message translates to:
  /// **'Legend:'**
  String get legend;

  /// Legend item for on-time days
  ///
  /// In en, this message translates to:
  /// **'On time arrival'**
  String get onTimeArrival;

  /// Legend item for late days
  ///
  /// In en, this message translates to:
  /// **'Late arrival'**
  String get lateArrival;

  /// Legend item for days without data
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get noRecord;

  /// Reward dialog title
  ///
  /// In en, this message translates to:
  /// **'Manage Reward'**
  String get manageReward;

  /// Reward name input label
  ///
  /// In en, this message translates to:
  /// **'Reward Name'**
  String get rewardName;

  /// Reward name hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Pizza night 🍕'**
  String get rewardNameHint;

  /// Reward templates section header
  ///
  /// In en, this message translates to:
  /// **'Quick Suggestions'**
  String get quickSuggestions;

  /// Streak goal input label
  ///
  /// In en, this message translates to:
  /// **'Streak Goal'**
  String get streakGoal;

  /// Days unit label
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive status label
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Progress section header
  ///
  /// In en, this message translates to:
  /// **'Current Progress:'**
  String get currentProgress;

  /// Progress counter
  ///
  /// In en, this message translates to:
  /// **'{current} out of {total} days'**
  String daysProgress(int current, int total);

  /// Encouragement message
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// Reward not started message
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get notStartedYet;

  /// Validation error for empty reward name
  ///
  /// In en, this message translates to:
  /// **'Please enter a reward name'**
  String get pleaseEnterRewardName;

  /// Reward saved success message
  ///
  /// In en, this message translates to:
  /// **'Reward updated: {name}'**
  String rewardUpdated(String name);

  /// Reward save error message
  ///
  /// In en, this message translates to:
  /// **'Error saving reward: {error}'**
  String errorSavingReward(String error);

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Movie night'**
  String get rewardMovieNight;

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Pizza dinner'**
  String get rewardPizzaDinner;

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Extra game time'**
  String get rewardExtraGameTime;

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Park visit'**
  String get rewardParkVisit;

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Art project'**
  String get rewardArtProject;

  /// Reward template
  ///
  /// In en, this message translates to:
  /// **'Ice cream outing'**
  String get rewardIceCreamOuting;

  /// Default reward name for first launch
  ///
  /// In en, this message translates to:
  /// **'Movie night with popcorn 🍿'**
  String get defaultRewardName;

  /// App title on splash screen
  ///
  /// In en, this message translates to:
  /// **'Morning Mission'**
  String get splashTitle;

  /// App subtitle on splash screen
  ///
  /// In en, this message translates to:
  /// **'Win the morning'**
  String get splashSubtitle;

  /// Reward goal section header
  ///
  /// In en, this message translates to:
  /// **'🎁 Reward Goal'**
  String get rewardGoal;

  /// Today's mission header with goal
  ///
  /// In en, this message translates to:
  /// **'Today\'s Mission: Arrive on time!'**
  String get todaysMissionArriveOnTime;

  /// Tomorrow's mission header with goal
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s Mission: Arrive on time!'**
  String get tomorrowsMissionArriveOnTime;

  /// Mission header for specific date with goal
  ///
  /// In en, this message translates to:
  /// **'{date} Mission: Arrive on time!'**
  String missionForDateArriveOnTime(String date);

  /// Manage button label
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// Reward achieved message
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations! You earned {rewardName}'**
  String rewardCongratulations(String rewardName);

  /// Reward almost achieved message
  ///
  /// In en, this message translates to:
  /// **'Almost there! 🚀 1 day to earn {rewardName}'**
  String rewardAlmostThere(String rewardName);

  /// Reward halfway message
  ///
  /// In en, this message translates to:
  /// **'Halfway there! 🔥 {days} days to earn {rewardName}'**
  String rewardHalfway(int days, String rewardName);

  /// Reward days remaining message
  ///
  /// In en, this message translates to:
  /// **'Only {days} {daysWord} to earn {rewardName}'**
  String rewardDaysRemaining(int days, String daysWord, String rewardName);

  /// Singular day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// Motivational message 1
  ///
  /// In en, this message translates to:
  /// **'You\'ve got this!'**
  String get motivationYouveGotThis;

  /// Motivational message 2
  ///
  /// In en, this message translates to:
  /// **'Let\'s do this!'**
  String get motivationLetsDoThis;

  /// Motivational message 3
  ///
  /// In en, this message translates to:
  /// **'Ready to succeed!'**
  String get motivationReadyToSucceed;

  /// Motivational message 4
  ///
  /// In en, this message translates to:
  /// **'Time to shine!'**
  String get motivationTimeToShine;

  /// Motivational message 5
  ///
  /// In en, this message translates to:
  /// **'You can do it!'**
  String get motivationYouCanDoIt;

  /// Wake up time label in mission frame
  ///
  /// In en, this message translates to:
  /// **'Wake up at:'**
  String get wakeUpAt;

  /// Leave time label in mission frame
  ///
  /// In en, this message translates to:
  /// **'Leave at:'**
  String get leaveAt;

  /// Streak level progress message
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day until next level! 🎉} other{{days} days until next level! 🚀}}'**
  String daysUntilNextLevel(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
