// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'A Tiempo por la Mañana';

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
  String get arriveBy => 'Llegar antes de';

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
  String get arrivalConfirmation => 'Confirmación de Llegada';

  @override
  String get arrivedOnTime => '¡Llegaste a tiempo!';

  @override
  String get arrivedLate =>
      'Llegaste un poco tarde, pero está bien. ¡Mañana es una nueva oportunidad!';

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
}
