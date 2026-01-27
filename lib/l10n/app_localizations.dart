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
  /// **'Morning On Time'**
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

  /// Arrival deadline label
  ///
  /// In en, this message translates to:
  /// **'Arrive by'**
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

  /// Start button on setup screen
  ///
  /// In en, this message translates to:
  /// **'Start the Journey'**
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
