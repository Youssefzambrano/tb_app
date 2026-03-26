import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionesService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'evita_tb_channel';
  static const _channelName = 'Evita TB';

  static Future<void> inicializar() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> programarNotificaciones() async {
    await _plugin.cancelAll();
    await _programarRecordatorioDosis();
    await _programarRecordatorioAutochequeo();
    await _programarRecordatorioEducativo();
  }

  /// Daily at 08:00 — reminder to take the dose
  static Future<void> _programarRecordatorioDosis() async {
    await _plugin.zonedSchedule(
      0,
      'Recordatorio de dosis',
      'No olvides tomar tu medicamento hoy. ¡Tu salud importa!',
      _proximaInstanciaHora(8, 0),
      _detalles(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Every Monday at 09:00 — weekly autochequeo reminder
  static Future<void> _programarRecordatorioAutochequeo() async {
    await _plugin.zonedSchedule(
      1,
      'Autochequeo semanal',
      'Es lunes, momento de realizar tu autochequeo semanal.',
      _proximaInstanciaDiaHora(DateTime.monday, 9, 0),
      _detalles(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Every Wednesday at 18:00 — educational module reminder
  static Future<void> _programarRecordatorioEducativo() async {
    await _plugin.zonedSchedule(
      2,
      'Módulo educativo',
      'Aprende más sobre tu tratamiento. ¡Revisa el módulo educativo!',
      _proximaInstanciaDiaHora(DateTime.wednesday, 18, 0),
      _detalles(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static NotificationDetails _detalles() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(android: android);
  }

  static tz.TZDateTime _proximaInstanciaHora(int hora, int minuto) {
    final ahora = tz.TZDateTime.now(tz.local);
    var programado = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      hora,
      minuto,
    );
    if (programado.isBefore(ahora)) {
      programado = programado.add(const Duration(days: 1));
    }
    return programado;
  }

  static tz.TZDateTime _proximaInstanciaDiaHora(
    int diaSemana,
    int hora,
    int minuto,
  ) {
    var programado = _proximaInstanciaHora(hora, minuto);
    while (programado.weekday != diaSemana) {
      programado = programado.add(const Duration(days: 1));
    }
    return programado;
  }
}
