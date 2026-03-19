// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Never Late';

  @override
  String get todaysMission => 'Misión de Hoy';

  @override
  String get arriveOnTime => '¡Llegar a la escuela a tiempo!';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Días de Racha',
      one: 'Día de Racha',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => '🌅 ¡Buenos Días!';

  @override
  String get missionMessage =>
      'La misión de hoy es llegar a la escuela a tiempo. ¡Vamos!';

  @override
  String get quickCheckIn => '⏰ Registro Rápido';

  @override
  String get howAreThings => '¿Cómo van las cosas esta mañana?';

  @override
  String get goingWell => 'Todo Bien';

  @override
  String get runningTight => 'Voy Justo';

  @override
  String get leaveHomeSoon => '🏃 ¡Salir Pronto!';

  @override
  String get leaveHomeSoonMessage =>
      '¡En cinco minutos debemos salir de casa, apúrate!';

  @override
  String get leaveHomeNow => '🚪 ¡Salir Ahora!';

  @override
  String get leaveHomeNowMessage => 'Salimos de casa ahora o llegaremos tarde.';

  @override
  String get openAppToSeeCountdown =>
      'Abre la aplicación para ver el temporizador de cuenta regresiva.';

  @override
  String get arrivalCheck => '🎯 ¿Hemos llegado a tiempo?';

  @override
  String get arrivalCheckMessage => 'Toca para confirmar tu estado de llegada';

  @override
  String get yesWeHave => 'Sí, llegamos';

  @override
  String get noWeHavent => 'No, no llegamos';

  @override
  String get arrivedAtSchool => 'Llegué a la Escuela';

  @override
  String get wakeUp => 'Despertar';

  @override
  String get leaveHome => 'Salir de casa';

  @override
  String get arriveBy => 'Llegar antes de:';

  @override
  String get todaysSchedule => 'Horario de Hoy';

  @override
  String get monthlyView => 'Vista Mensual';

  @override
  String get rewards => 'Recompensas';

  @override
  String get greatJob => '¡Excelente trabajo! ¡Llegaste a tiempo hoy!';

  @override
  String get didntMakeIt => 'No lo logramos hoy. ¡Mañana es un nuevo día!';

  @override
  String get keepUpGreatWork => '¡Sigue así, excelente trabajo!';

  @override
  String get tryAgainTomorrow => '¡Inténtalo de nuevo mañana!';

  @override
  String get arrivalConfirmation => 'Confirmación de Llegada';

  @override
  String get arrivedOnTime => '¡Llegaste a tiempo!';

  @override
  String get arrivedLate =>
      'Llegaste un poco tarde, pero está bien. ¡Mañana es una nueva oportunidad!';

  @override
  String get arrivalTime => 'Hora de llegada:';

  @override
  String get confirm => 'Confirmar';

  @override
  String get setupMorningRoutine => 'Configura tu Rutina Matutina';

  @override
  String get setupDescription =>
      '¡Planifiquemos tu mañana para ayudarte a llegar a la escuela a tiempo!';

  @override
  String get wakeUpTime => 'Hora de Despertar';

  @override
  String get leaveHomeTime => 'Hora de Salir de Casa';

  @override
  String get latestArrivalTime => 'Hora Límite de Llegada';

  @override
  String get startTheJourney => 'Guardar Plan';

  @override
  String get settingUpRoutine => 'Configurando tu rutina matutina...';

  @override
  String get routineSaved => '✅ ¡Rutina matutina guardada exitosamente!';

  @override
  String errorSavingSettings(String error) {
    return 'Error al guardar la configuración: $error';
  }

  @override
  String get settings => 'Configuración';

  @override
  String get onTime => 'A Tiempo';

  @override
  String get late => 'Tarde';

  @override
  String get noData => 'Sin datos';

  @override
  String get timeRemaining => 'Tiempo Restante';

  @override
  String get hurryCritical => '¡APÚRATE! ¡Casi llegamos!';

  @override
  String get hurryUp => '¡Apúrate!';

  @override
  String get onTrack => '¡Vamos bien!';

  @override
  String get journeyInProgress => 'Viaje en Progreso';

  @override
  String get onboardingProblemHeadline => '¿Las mañanas son una lucha diaria?';

  @override
  String get onboardingProblemPoint1 =>
      '¿Llegar tarde a la escuela a pesar de tus mejores esfuerzos?';

  @override
  String get onboardingProblemPoint2 =>
      '¿Mañanas llenas de caos, recordatorios constantes y estrés?';

  @override
  String get onboardingProblemPoint3 =>
      '¿Niños sin sentido de urgencia mientras tú vas atrasado?';

  @override
  String get onboardingSolutionHeadline =>
      'Convierte las mañanas en una misión';

  @override
  String get onboardingSolutionPoint1 =>
      'Never Late ayuda a tu familia a llegar a tiempo consistentemente';

  @override
  String get onboardingSolutionPoint2 =>
      'Recordatorios por voz en momentos clave—sin pantallas, sin listas de tareas';

  @override
  String get onboardingSolutionPoint3 =>
      'Motiva con rachas y recompensas, no con culpa o presión';

  @override
  String get onboardingSolutionPoint4 =>
      'La aplicación se activa sola. Tú solo vive tu mañana.';

  @override
  String get onboardingHowItWorksHeadline =>
      'Apoyo automático durante toda la mañana';

  @override
  String get onboardingHowItWorksPoint1 =>
      'Mensaje de bienvenida establece la misión del día';

  @override
  String get onboardingHowItWorksPoint2 =>
      'Registros de voz cada 5 minutos para mantenerte en camino';

  @override
  String get onboardingHowItWorksPoint3 =>
      'Cuenta regresiva cuando es hora de salir';

  @override
  String get onboardingHowItWorksPoint4 =>
      '¡Confirma tu llegada para celebrar el éxito y construir tu racha!';

  @override
  String get onboardingPermissionsHeadline =>
      'Dos permisos rápidos para empezar';

  @override
  String get onboardingPermissionsIntro =>
      'Para que la aplicación funcione correctamente, necesitamos:';

  @override
  String get onboardingPermissionNotifications => '📬 Notificaciones';

  @override
  String get onboardingPermissionNotificationsDesc =>
      'Para enviar recordatorios por voz y alertas de tiempo durante tu mañana';

  @override
  String get onboardingPermissionBattery => '🔋 Batería Sin Restricciones';

  @override
  String get onboardingPermissionBatteryDesc =>
      'Para asegurar que las alarmas suenen a tiempo incluso cuando tu teléfono esté bloqueado o en modo de suspensión';

  @override
  String get onboardingPermissionExplanation =>
      'Por qué importa el permiso de batería: Android pone las aplicaciones a dormir para ahorrar energía. Sin este permiso, las alarmas matutinas podrían no despertarse a tiempo cuando más las necesitas.';

  @override
  String get onboardingGrantPermissions => 'Otorgar Permisos y Continuar';

  @override
  String get onboardingPermissionsRequired => 'Permisos Requeridos';

  @override
  String get onboardingPermissionsRequiredMessage =>
      'Never Late necesita ambos permisos para funcionar correctamente. Sin ellos, las alarmas podrían no sonar cuando tu familia más las necesita.\n\nPor favor otorga ambos permisos de Notificaciones y Batería Sin Restricciones para continuar.';

  @override
  String get onboardingExitApp => 'Salir de la App';

  @override
  String get onboardingTryAgain => 'Intentar de Nuevo';

  @override
  String get onboardingError => 'Error';

  @override
  String onboardingErrorMessage(String error) {
    return 'Ocurrió un error al solicitar permisos:\n\n$error';
  }

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get lowVolume => 'Volumen Bajo';

  @override
  String lowVolumeMessage(int volume) {
    return 'Tu volumen multimedia está al $volume%.\n\nConsidera aumentarlo para escuchar los mensajes de voz matutinos.';
  }

  @override
  String get okIllAdjustIt => 'OK, lo ajustaré';

  @override
  String get dndEnabled => 'No Molestar está Activado';

  @override
  String get dndEnabledMessage =>
      'El modo No Molestar está activo en tu dispositivo.\n\nLos mensajes de voz matutinos y los sonidos de notificación no se reproducirán mientras esté activado.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get streakLevelBeginner => 'Corredor Principiante';

  @override
  String get streakLevelOccasional => 'Corredor Ocasional';

  @override
  String get streakLevelPro => 'Corredor Pro';

  @override
  String get streakLevelChampion => 'Corredor Campeón';

  @override
  String get streakLevelUltimate => 'Jaguar Definitivo';

  @override
  String get testAllAlarms =>
      '🧪 Probar Todas las Alarmas (Recorrido de 22 Minutos)';

  @override
  String get testAllAlarmsDescription =>
      'Esto probará TODOS los tipos de alarma en ~22 minutos:';

  @override
  String get testAllAlarmsDetails =>
      '✅ Alarma de despertar (T+2 min)\n✅ Alarma de control #1 (T+12 min)\n✅ Sal Pronto de Casa (T+13 min)\n✅ Salir de Casa → comienza cuenta regresiva (T+18 min)\n✅ Control Pre-Llegada (T+20 min)\n✅ Fecha límite de llegada (T+22 min)\n\nToca \"Llegué\" antes de la fecha límite para probar éxito.\nDeja que el temporizador expire para probar fallo.\n\n⚠️ No se puede ejecutar entre 11:38 PM - medianoche.';

  @override
  String get startTest => '🚀 Iniciar Prueba';

  @override
  String get cannotScheduleNotifications =>
      '❌ No se pueden programar notificaciones - ¡permiso no otorgado!';

  @override
  String get testNotificationSuccess =>
      '✅ ¡Mostrando prueba AHORA! Prueba programada en 30s. ¡MANTÉN LA APP ABIERTA y espérala!';

  @override
  String errorWithDetails(String error) {
    return '❌ Error: $error';
  }

  @override
  String testCannotRunMidnight(int minutes) {
    return '❌ ¡La prueba no puede ejecutarse - muy cerca de medianoche!\nSolo $minutes minutos hasta medianoche.\nLa prueba necesita 22 minutos. Por favor intenta más temprano.';
  }

  @override
  String get testStarted =>
      '🧪 ¡Prueba Iniciada! (recorrido de 22 minutos)\n• Despertar: en 2 minutos\n• Control #1: en 12 minutos (¡NUEVO!)\n• Sal Pronto de Casa: en 13 minutos\n• Salir de Casa: en 18 minutos → comienza cuenta regresiva\n• Control Pre-Llegada: en 20 minutos\n• Fecha límite de llegada: en 22 minutos\n• Permanece en pantalla para observar las alarmas';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get saturday => 'Sáb';

  @override
  String get sunday => 'Dom';

  @override
  String get activeDays => '📅 Días Activos';

  @override
  String get weekdaysOnly => 'Solo Días Laborales';

  @override
  String get everyDay => 'Todos los Días';

  @override
  String get viewScheduledAlarms => 'Ver Alarmas Programadas (Pruebas)';

  @override
  String get totalDays => 'Días Totales';

  @override
  String get noDataForMonth => 'Sin datos para este mes';

  @override
  String get legend => 'Leyenda:';

  @override
  String get onTimeArrival => 'Llegada a tiempo';

  @override
  String get lateArrival => 'Llegada tarde';

  @override
  String get noRecord => 'Sin registro';

  @override
  String get rewardWon => 'Recompensa ganada';

  @override
  String get manageReward => 'Gestionar Recompensa';

  @override
  String get rewardName => 'Nombre de la Recompensa';

  @override
  String get rewardNameHint => 'ej., Noche de pizza 🍕';

  @override
  String get quickSuggestions => 'Sugerencias Rápidas';

  @override
  String get streakGoal => 'Meta de Racha';

  @override
  String get days => 'días';

  @override
  String get active => 'Activa';

  @override
  String get inactive => 'Inactiva';

  @override
  String get currentProgress => 'Progreso Actual:';

  @override
  String daysProgress(int current, int total) {
    return '$current de $total días';
  }

  @override
  String get keepItUp => '¡Sigue así!';

  @override
  String get notStartedYet => 'Aún no iniciada';

  @override
  String get pleaseEnterRewardName =>
      'Por favor ingresa un nombre para la recompensa';

  @override
  String rewardUpdated(String name) {
    return 'Recompensa actualizada: $name';
  }

  @override
  String errorSavingReward(String error) {
    return 'Error al guardar recompensa: $error';
  }

  @override
  String get rewardMovieNight => 'Noche de película';

  @override
  String get rewardPizzaDinner => 'Cena de pizza';

  @override
  String get rewardExtraGameTime => 'Tiempo extra de juego';

  @override
  String get rewardParkVisit => 'Visita al parque';

  @override
  String get rewardArtProject => 'Proyecto de arte';

  @override
  String get rewardIceCreamOuting => 'Salida a heladería';

  @override
  String get defaultRewardName => 'Noche de película con palomitas 🍿';

  @override
  String get splashTitle => 'Never Late';

  @override
  String get splashSubtitle => 'Gana la mañana';

  @override
  String get rewardGoal => '🎁 Meta de Recompensa';

  @override
  String get todaysMissionArriveOnTime => 'Misión de Hoy: ¡Llegar a tiempo!';

  @override
  String get tomorrowsMissionArriveOnTime =>
      'Misión de Mañana: ¡Llegar a tiempo!';

  @override
  String missionForDateArriveOnTime(String date) {
    return 'Misión del $date: ¡Llegar a tiempo!';
  }

  @override
  String get manage => 'Gestionar';

  @override
  String rewardCongratulations(String rewardName) {
    return '🎉 ¡Felicitaciones! Ganaste $rewardName';
  }

  @override
  String rewardAlmostThere(String rewardName) {
    return '¡Casi llegamos! 🚀 1 día para ganar $rewardName';
  }

  @override
  String rewardHalfway(int days, String rewardName) {
    return '¡A mitad de camino! 🔥 $days días para ganar $rewardName';
  }

  @override
  String rewardDaysRemaining(int days, String daysWord, String rewardName) {
    return 'Solo $days $daysWord para ganar $rewardName';
  }

  @override
  String get day => 'día';

  @override
  String get motivationYouveGotThis => '¡Tú puedes!';

  @override
  String get motivationLetsDoThis => '¡Hagámoslo!';

  @override
  String get motivationReadyToSucceed => '¡Listo para triunfar!';

  @override
  String get motivationTimeToShine => '¡Hora de brillar!';

  @override
  String get motivationYouCanDoIt => '¡Tú puedes hacerlo!';

  @override
  String get wakeUpAt => 'Despertar a las:';

  @override
  String get leaveAt => 'Salir a las:';

  @override
  String daysUntilNextLevel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '¡$days días hasta el siguiente nivel! 🚀',
      one: '¡1 día hasta el siguiente nivel! 🎉',
    );
    return '$_temp0';
  }

  @override
  String get journeyGettingReady => 'Preparándose';

  @override
  String get journeyOnTheWay => 'En Camino';

  @override
  String get journeyLeaveBy => 'Salir a las';

  @override
  String get journeyArriveBy => 'Llegar antes de';

  @override
  String nextAlarmIn(String time) {
    return 'Próxima alarma en $time';
  }

  @override
  String nextAlarmTomorrow(String time) {
    return 'Próxima alarma mañana a las $time';
  }

  @override
  String get noUpcomingAlarms => 'Sin alarmas próximas';

  @override
  String get bannerWakeUp =>
      '☀️ ¡Buenos días! La misión de hoy: ¡llegar a tiempo!';

  @override
  String bannerMinutesLeft(int minutes) {
    return '⏰ $minutes minutos para salir de casa';
  }

  @override
  String get bannerLeaveSoon => '🚨 ¡Casi es hora de salir! ¡Prepárate!';

  @override
  String get bannerLeaveNow => '🚗 ¡Es hora de salir! ¡Vamos!';

  @override
  String bannerOnTheWay(String time) {
    return '🚗 ¡En camino! Llegar antes de las $time';
  }

  @override
  String get bannerAlmostThere => '🎯 ¡Casi llegamos! Confirma tu llegada';

  @override
  String get bannerLastChance => '🚨 ¡Última oportunidad! ¡Confirma ahora!';

  @override
  String get greetingMorning => 'Buenos días ☀️';

  @override
  String get greetingAfternoon => 'Buenas tardes 🌤️';

  @override
  String get greetingEvening => 'Buenas noches 🌙';
}
