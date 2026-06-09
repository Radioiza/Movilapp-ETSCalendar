import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_datos;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants/app_constants.dart';

/// Servicio de **notificaciones locales** para recordar al usuario la fecha
/// de su examen (requerimiento técnico irrenunciable).
///
/// Encapsula `flutter_local_notifications` detrás de una API sencilla y
/// agnóstica de la entidad `Examen`, de modo que la capa de presentación
/// solo necesita indicar *qué* recordar y *cuándo* — sin acoplar este
/// servicio (que vive junto al dominio) a otros features.
class NotificacionService {
  NotificacionService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) {
      return;
    }

    tz_datos.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const AndroidInitializationSettings configAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings configIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: configAndroid, iOS: configIOS),
    );

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      AppConstants.canalRecordatoriosId,
      AppConstants.canalRecordatoriosNombre,
      description: AppConstants.canalRecordatoriosDescripcion,
      importance: Importance.high,
    ));

    _inicializado = true;
  }

  /// Solicita permiso de notificaciones (Android 13+ / iOS).
  Future<bool> solicitarPermisos() async {
    final bool? otorgadoAndroid = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final bool? otorgadoIOS = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (otorgadoAndroid ?? true) && (otorgadoIOS ?? true);
  }

  /// Programa un recordatorio único en [fechaHora]. Si esa fecha ya pasó,
  /// no se programa nada (evita notificaciones retroactivas).
  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
  }) async {
    await inicializar();

    final tz.TZDateTime momento = tz.TZDateTime.from(fechaHora, tz.local);
    if (momento.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id,
        titulo,
        cuerpo,
        momento,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.canalRecordatoriosId,
            AppConstants.canalRecordatoriosNombre,
            channelDescription: AppConstants.canalRecordatoriosDescripcion,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Exception catch (error, trazado) {
      // No es crítico para el flujo principal: se reporta y se continúa.
      debugPrint('No fue posible programar el recordatorio $id: $error\n$trazado');
    }
  }

  Future<void> cancelar(int id) => _plugin.cancel(id);

  /// Deriva un identificador entero estable a partir del id del examen,
  /// requerido por `flutter_local_notifications`.
  static int idDesde(String examenId) => examenId.hashCode & 0x7fffffff;
}
