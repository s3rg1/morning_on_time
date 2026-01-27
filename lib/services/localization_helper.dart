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
        return '¡Buenos días! La misión de hoy es llegar a la escuela a tiempo. ¡Vamos!';
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
        return '¡En cinco minutos debemos salir de casa, apúrate!';
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
  
  /// Get localized action button text for "Running Tight"
  static Future<String> getRunningTightText() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return '⚡ Voy Justo';
      case 'en':
      default:
        return '⚡ Running Tight';
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
}
