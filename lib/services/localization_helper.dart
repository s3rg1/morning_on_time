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
  
  /// Get localized wake-up message templates for random selection
  static Future<List<String>> getWakeUpMessages() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return [
          '¡La misión de hoy es llegar a la escuela a tiempo. ¡A por ello!',
          '¡Buenos días, equipo! Hoy vamos a llegar a la escuela justo a tiempo. ¡Hagámoslo juntos!',
          '¡Arriba chavales! Nuestra misión familiar de hoy: tranquilos, felices y a tiempo en la escuela.',
          '¡Nuevo día, nueva aventura! Vamos a prepararnos y llegar a la escuela justo a tiempo.',
          '¡Buenos días! Pequeños pasos, gran victoria. Salgamos de casa a tiempo hoy.',
          '¡Despertad, superhéroes! Nuestra misión es una mañana tranquila y llegar puntuales.',
          '¡Buenos días! Empecemos el día con sonrisas y lleguemos a la escuela justo a tiempo.',
          '¡Familia, reunión! Trabajemos juntos para llegar a la escuela a tiempo.',
          '¡Buenos días! Hagamos que el día de hoy sea fácil, divertido y lleguemos puntuales.',
          '¡Es un nuevo día! Ayudémonos unos a otros a prepararnos y llegar a tiempo.',
          '¡Buenos días a todos! Hoy es un día fantástico para llegar a la escuela a tiempo.',
        ];
      case 'en':
      default:
        return [
          "Today's mission is to arrive at school on time. Let's go!",
          "Good morning, team! Today we're heading to school right on time—let's do it together!",
          'Rise and shine! Our family mission today: calm, happy, and on time to school.',
          "New day, new adventure! Let's get ready and arrive at school right on time.",
          "Good morning! Small steps, big win—let's get out the door on time today.",
          'Wake up, superheroes! Our mission is a smooth morning and an on-time arrival.',
          "Good morning! Let's start the day with smiles and make it to school right on time.",
          'Team family, assemble! Today we move together and arrive at school on time.',
          "Good morning! Let's make today easy, fun, and right on schedule.",
          "It's a brand new day! Let's help each other get ready and be on time.",
          "Morning, everyone! Let's win the day early by arriving at school on time.",
        ];
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
  
  /// Get localized leave home soon messages
  static Future<List<String>> getLeaveHomeSoonMessages() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return [
          '¡5 minutos! Zapatos puestos, mochilas listas. ¡Vamos, equipo!',
          '¡Cuenta atrás! Salimos en 5 minutos. ¡Terminemos con fuerza!',
          '¡Última llamada! Lavaos los dientes, poneos los zapatos, coged la mochila. ¡5 minutos!',
          '¡Solo quedan 5 minutos! Terminemos y salgamos.',
          '¡Rápido, equipo! En 5 minutos salimos por la puerta. ¡Ya casi estamos!',
          '¡Últimos 5 minutos! ¡Completemos la misión y vámonos!',
          '¡Modo turbo activado! ¡5 minutos para salir!',
          '¡Recta final! En 5 minutos nos vamos. ¡Hagámoslo juntos!',
          '¡Comprobación rápida! ¿Dientes limpios? ¿Zapatos puestos? ¿Mochila lista? ¡Salimos en 5 minutos!',
          '¡Última llamada! Lavaos los dientes, poneos los zapatos, coged la mochila. ¡5 minutos!',
        ];
      case 'en':
      default:
        return [
          "5 minutes to go! Shoes on, bags ready—let's move, team!",
          "Final countdown! We leave in 5 minutes—let's finish strong!",
          'Final call! Brush teeth, put your shoes on, grab your backpack—5 minutes!',
          "Only 5 minutes left! Let's wrap things up and head out.",
          "Quick, team! In 5 minutes we're out the door—almost there!",
          "Last 5 minutes! Let's complete the mission and go!",
          'Speed mode ON! 5 minutes until we head out!',
          "Final stretch! In 5 minutes we leave—let's do this together!",
          'Quick check! Teeth clean? Shoes on? Backpack ready? We leave in 5 minutes!',
          'Final call! Brush teeth, put your shoes on, grab your backpack—5 minutes!',
        ];
    }
  }
  
  /// Get localized leave home now messages
  static Future<List<String>> getLeaveHomeNowMessages() async {
    final locale = await getLocale();
    switch (locale) {
      case 'es':
        return [
          '¡Es la hora! ¡Todos fuera, nos vamos ya!',
          '¡Se acabó el tiempo, equipo! Zapatos puestos, mochilas listas. ¡Vamos!',
          '¡Vamos! ¡Salimos ahora mismo, misión en marcha!',
          '¿Todo listo? ¡Puerta abierta, nos vamos ya!',
          '¡Este es el momento! ¡Coged vuestras cosas y vámonos!',
          '¡No más esperas, equipo, nos vamos ya!',
          '¡Empieza la misión! ¡Por la puerta, vamos!',
          '¡Venga, equipo! ¡Mochilas, zapatos y a salir!',
          '¡Hora de despegar! ¡Todos fuera, vamos!',
          '¡En marcha! Es hora de salir. ¡Nos vemos fuera!',
        ];
      case 'en':
      default:
        return [
          "It's go time! Everyone out—we're leaving now!",
          "Time's up, team! Shoes on, backpacks ready—let's head out!",
          "Let's go! We leave right now—mission in action!",
          "All set? Doors open—we're heading out now!",
          "This is it! Grab your things and let's go!",
          "No more waiting—team, we're leaving now!",
          "Mission start! Out the door, let's go!",
          'Alright team—bags, shoes, and out we go!',
          "Launch time! Everyone out, let's move!",
          "Let's roll! It's time to leave—see you outside!",
        ];
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
              'Hemos empezado genial, mantengamos la mañana tranquila y fácil.',
              'Mucho tiempo por delante, equipo. Disfrutemos preparándonos juntos.',
              'Sin prisa pero sin pausa, así es como ganamos nuestra mañana.',
              'Tenemos el tiempo de nuestro lado. Sigamos con energía tranquila.',
              '¡Buen trabajo empezando el día! Sigamos así.',
              'Sin prisas, solo avances. Todo va bien.',
              'Lo estamos haciendo genial hasta ahora. Mantengamos el buen ritmo.',
              'Mañanas tranquilas, mañanas felices. ¡Sigamos así!',
              'Todo bajo control. Continuemos paso a paso.',
              'Solo buenas vibras. Sigamos avanzando juntos.',
            ]
          : [
              "We're off to a great start—let's keep the morning smooth and easy.",
              "Plenty of time ahead, team. Let's enjoy getting ready together.",
              "Nice and steady—this is how we win our morning.",
              "We've got time on our side. Let's keep moving with calm energy.",
              "Great job starting the day! Let's keep things flowing.",
              'No rush, just progress—everything is going well.',
              "We're doing great so far. Let's keep the good rhythm.",
              "Calm mornings, happy mornings—let's keep it up.",
              "Everything is under control. Let's continue step by step.",
              "Good vibes only—let's keep moving forward together.",
            ];
    }

    if (remainingRatio > 0.50) {
      return isSpanish
          ? [
              'Lo estamos haciendo bien. Quedan {minutes} minutos para seguir en buen camino.',
              '¡Buen progreso! {minutes} minutos para estar listos.',
              'Sigamos así. Quedan {minutes} minutos.',
              '¡Vamos por la mitad! Quedan {minutes} minutos.',
              'Seguimos en buena forma. {minutes} minutos por delante.',
              'Buen ritmo, equipo. Quedan {minutes} minutos para terminar bien.',
              'Tenemos {minutes} minutos. Usémoslos bien.',
              'Todo va según lo previsto. Quedan {minutes} minutos.',
              'Mantengamos el ritmo. {minutes} minutos para estar listos.',
              '¡Vamos bien! {minutes} minutos para salir.',
            ]
          : [
              "We're doing well—{minutes} minutes left to keep things on track.",
              'Nice progress! {minutes} minutes to be ready to go.',
              "Let's keep it going—{minutes} minutes left.",
              "We're halfway there! {minutes} minutes remaining.",
              'Still in great shape—{minutes} minutes to go.',
              'Good pace, team—{minutes} minutes left to finish strong.',
              "We've got {minutes} minutes—let's use them wisely.",
              "Everything's on track—{minutes} minutes left.",
              'Keep the rhythm—{minutes} minutes to be ready.',
              'Looking good! {minutes} minutes until it\'s time to leave.',
            ];
    }

    return isSpanish
        ? [
            'Muy bien equipo, a concentrarse. ¡Solo quedan {minutes} minutos!',
            '¡Vamos! Salimos en {minutes} minutos. ¡Recta final!',
            '¡Este es el momento! Quedan {minutes} minutos. ¡A moverse!',
            'Entramos en la fase final. {minutes} minutos por delante.',
            '¡No bajemos el ritmo ahora! Quedan {minutes} minutos.',
            'Terminemos con fuerza. {minutes} minutos para salir.',
            '¡Concentración! Solo quedan {minutes} minutos para estar listos.',
            '¡Vamos! Tenemos una racha que superar. Quedan {minutes} minutos.',
            'Hora de terminar. {minutes} minutos y salimos por la puerta.',
            '¡Todos a una! Quedan {minutes} minutos. ¡A por ello!',
          ]
        : [
            'Alright team, focus time—only {minutes} minutes left.',
            "Let's go! We leave in {minutes} minutes—final stretch!",
            "This is the moment—{minutes} minutes left, let's move!",
            "We're entering the final phase—{minutes} minutes to go.",
            'No slowing down now—{minutes} minutes left!',
            "Let's finish strong—{minutes} minutes until we head out.",
            'Quick focus! Only {minutes} minutes left to be ready.',
            "Come on! We've got a streak to beat—{minutes} minutes left.",
            "Time to wrap up—{minutes} minutes and we're out the door.",
            "All hands on deck—{minutes} minutes left, let's do this!",
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
