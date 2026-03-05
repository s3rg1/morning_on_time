import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for localization in background isolates
/// Since background isolates can't access Flutter's BuildContext,
/// we store the locale preference and provide hardcoded translations
class LocalizationHelper {
  static const String _localeKey = 'app_locale';
  
  /// Save the current locale
  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
  
  /// Get the saved locale or device locale
  static Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      return savedLocale;
    }
    
    // Get device locale
    final deviceLocale = Platform.localeName; // e.g., 'en_US', 'es_ES'
    final languageCode = deviceLocale.split('_')[0]; // Extract 'en' or 'es'
    return languageCode;
  }
  
  /// Get the TTS language code (e.g., 'en-US', 'es-ES')
  static Future<String> getTtsLanguage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'es-ES';
      case 'en':
      default:
        return 'en-US';
    }
  }
  
  /// Get localized wake-up message
  static Future<String> getWakeUpMessage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '¡Buenos días! Hoy vamos a llegar a la escuela a tiempo. ¡Vamos!';
      case 'en':
      default:
        return "Good morning! Today's mission is to arrive at school on time. Let's go!";
    }
  }
  
  /// Get localized check-in message
  static Future<String> getCheckInMessage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '¡Oye! ¿Cómo van las cosas esta mañana?';
      case 'en':
      default:
        return 'Hey! How are things going this morning?';
    }
  }
  
  /// Get localized leave home soon message
  static Future<String> getLeaveHomeSoonMessage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '¡En cinco minutos debemos salir de casa, vamos!';
      case 'en':
      default:
        return 'In five minutes we must leave home, hurry up!';
    }
  }
  
  /// Get localized leave home now message
  static Future<String> getLeaveHomeNowMessage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'Salimos de casa ahora o llegaremos tarde.';
      case 'en':
      default:
        return "We leave home now or we'll be late.";
    }
  }
  
  /// Get localized countdown timer text
  static Future<String> getOpenAppToSeeCountdown() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'Abre la aplicación para ver el temporizador de cuenta regresiva.';
      case 'en':
      default:
        return 'Open app to see countdown timer.';
    }
  }
  
  /// Get localized arrival check message
  static Future<String> getArrivalCheckMessage() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '¡Es hora de llegar! ¿Llegamos a tiempo?';
      case 'en':
      default:
        return "It's time to arrive! Are we on time?";
    }
  }
  
  /// Get localized notification title for wake-up
  static Future<String> getWakeUpTitle() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🌅 ¡Buenos Días!';
      case 'en':
      default:
        return '🌅 Good Morning!';
    }
  }
  
  /// Get localized notification title for check-in
  static Future<String> getCheckInTitle() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '⏰ Registro Rápido';
      case 'en':
      default:
        return '⏰ Quick Check-In';
    }
  }
  
  /// Get localized notification title for leave home soon
  static Future<String> getLeaveHomeSoonTitle() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🏃 ¡Salir Pronto!';
      case 'en':
      default:
        return '🏃 Leave Home Soon!';
    }
  }
  
  /// Get localized notification title for leave home now
  static Future<String> getLeaveHomeNowTitle() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🚪 ¡Salir Ahora!';
      case 'en':
      default:
        return '🚪 Leave Home Now!';
    }
  }
  
  /// Get localized action button text for "Going Well"
  static Future<String> getGoingWellText() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '✅ Todo Bien';
      case 'en':
      default:
        return '✅ Going Well';
    }
  }
  
  /// Get localized notification title for arrival check
  static Future<String> getArrivalCheckTitle() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🎯 ¿Hemos llegado a tiempo?';
      case 'en':
      default:
        return '🎯 Have we arrived on time?';
    }
  }
  
  /// Get localized notification body for arrival check
  static Future<String> getArrivalCheckBody() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'Toca para confirmar tu estado de llegada';
      case 'en':
      default:
        return 'Tap to confirm your arrival status';
    }
  }

  // --- Pre-Arrival Check Alarms (IDs 5, 7, 8) ---

  /// Pre-Arrival Check 1 (T-60s) - Gentle reminder
  static Future<String> getPreArrivalTitle1() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🎯 ¿Ya hemos llegado?';
      case 'en':
      default:
        return '🎯 Have we arrived already?';
    }
  }

  static Future<String> getPreArrivalBody1() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'No olvides confirmar tu llegada. ¡Queda 1 minuto!';
      case 'en':
      default:
        return "Don't forget to confirm your arrival. 1 minute left!";
    }
  }

  /// Pre-Arrival Check 2 (T-30s) - Urgent
  static Future<String> getPreArrivalTitle2() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '🎯 ¿Ya hemos llegado?';
      case 'en':
      default:
        return '🎯 Have we arrived already?';
    }
  }

  static Future<String> getPreArrivalBody2() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'No olvides confirmar tu llegada. ¡Quedan 30 segundos!';
      case 'en':
      default:
        return "Don't forget to confirm your arrival. 30 seconds left!";
    }
  }

  /// Pre-Arrival Check 3 (T-10s) - Critical / Last chance
  static Future<String> getPreArrivalTitle3() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '⚠️ ¡Última oportunidad!';
      case 'en':
      default:
        return '⚠️ Last chance!';
    }
  }

  static Future<String> getPreArrivalBody3() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'Confirma ahora o el día se marcará como tarde. ¡Quedan 10 segundos!';
      case 'en':
      default:
        return 'Confirm now or today will be marked as late. 10 seconds left!';
    }
  }
  
  /// Get localized action button text for "Yes, we have"
  static Future<String> getArrivedYesText() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '✅ Sí, llegamos';
      case 'en':
      default:
        return '✅ Yes, we have';
    }
  }
  
  /// Get localized action button text for "No, we haven't"
  static Future<String> getArrivedNoText() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '❌ No, no llegamos';
      case 'en':
      default:
        return '❌ No, we haven\'t';
    }
  }
  
  /// Get localized default reward name
  static Future<String> getDefaultRewardName() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return 'Noche de película con palomitas 🍿';
      case 'en':
      default:
        return 'Movie night with popcorn 🍿';
    }
  }

  /// Get localized checkpoint message templates by remaining time ratio
  static List<String> getCheckpointTemplates({
    required String ttsLanguage,
    required double remainingRatio,
  }) {
    final isSpanish = ttsLanguage == 'es-ES';

    if (remainingRatio > 0.75) {
      return isSpanish
          ? [
              '¡Vamos! Tenemos una racha que superar, salimos en {minutes} minutos.',
              '¿Qué, hoy no voy a ser el primero? Vamos, aún tenemos {minutes} minutos para salir.',
              'Hoy es un día fantástico para ser los primeros. Aún tenemos {minutes} minutos.',
            ]
          : [
              "Come on! We've a streak to beat, we're leaving in {minutes} minutes.",
              "What, I won't be the first? Come on, we still have {minutes} minutes to leave.",
              'Today is a fantastic day to be first. We still have {minutes} minutes.',
            ];
    }

    if (remainingRatio > 0.50) {
      return isSpanish
          ? [
              'He visto tortugas más rápidas. Nos quedan {minutes} minutos para salir.',
              '¿De verdad esperas llegar a tiempo? Date prisa, solo tenemos {minutes} minutos.',
              '¿Por qué os movéis tan lento? Tenemos que salir en {minutes} minutos.',
            ]
          : [
              "I've seen faster turtles. We have {minutes} minutes left to leave.",
              'Do you expect to arrive on time? Hurry, we only have {minutes} minutes left.',
              'Why are you moving so slowly? We need to leave in {minutes} minutes.',
            ];
    }

    return isSpanish
        ? [
            'Parecéis perezosos, corred porque solo os quedan {minutes} minutos.',
            'Nunca he visto una familia tan lenta. Os quedan {minutes} minutos.',
            '¡Rápido! Solo nos quedan {minutes} minutos.',
            '¿No me escucháis? Tenemos que salir en {minutes} minutos.',
          ]
        : [
            'You look like sloths, run because you only have {minutes} minutes left.',
            "I've never seen a family this slow. You have {minutes} minutes left.",
            'Hurry up! We have {minutes} minutes left to go.',
            'Are you deaf? We have to leave in {minutes} minutes.',
          ];
  }

  /// Get localized reward-specific checkpoint template by remaining ratio
  static String getCheckpointRewardTemplate({
    required String ttsLanguage,
    required double remainingRatio,
  }) {
    final isSpanish = ttsLanguage == 'es-ES';

    if (remainingRatio > 0.75) {
      return isSpanish
          ? '¡Vamos! Tenemos que salir en {minutes} minutos si queremos ganar {reward}.'
          : 'Come on, we have to leave in {minutes} minutes if we want to win {reward}.';
    }

    if (remainingRatio > 0.50) {
      return isSpanish
          ? 'Tenemos que salir en {minutes} minutos si queremos conseguir {reward}.'
          : 'We need to leave in {minutes} minutes if we want {reward}.';
    }

    return isSpanish
        ? '¿Aún quieres {reward}? Si no salimos en {minutes} minutos, no lo conseguiremos.'
        : "Do you still want {reward}? If we don't leave in {minutes} minutes, we won't get it.";
  }
}
