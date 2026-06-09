import 'package:add_2_calendar/add_2_calendar.dart';

import '../../exams/domain/entities/examen.dart';

/// Servicio de **exportación a formato .ics (iCalendar)** — los puntos
/// extra del requerimiento "Exportación" del Módulo Público.
///
/// Traduce cada [Examen] seleccionado a un evento de calendario estándar
/// (RFC 5545) y delega en `add_2_calendar` su entrega a la app de
/// calendario nativa del dispositivo (Google Calendar / Calendario de iOS),
/// que internamente lo serializa como evento iCalendar.
abstract final class IcsExportService {
  static const Duration _duracionExamen = Duration(hours: 2);

  /// Agrega un único examen al calendario del dispositivo.
  static Future<bool> agregarAlCalendario(Examen examen) {
    return Add2Calendar.addEvent2Cal(_eventoDesde(examen));
  }

  /// Agrega cada examen del calendario seleccionado, uno a uno. Devuelve la
  /// cantidad de eventos que se lograron entregar a la app de calendario.
  static Future<int> exportarVarios(List<Examen> examenes) async {
    int exitosos = 0;
    for (final Examen examen in examenes) {
      final bool agregado = await Add2Calendar.addEvent2Cal(_eventoDesde(examen));
      if (agregado) {
        exitosos++;
      }
    }
    return exitosos;
  }

  static Event _eventoDesde(Examen examen) {
    return Event(
      title: 'ETS · ${examen.unidadAprendizaje}',
      description: 'Examen a Título de Suficiencia\n'
          'Carrera: ${examen.carreraNombre} (${examen.semestre}.º semestre)\n'
          'Turno: ${examen.turno.etiqueta}\n'
          'Profesor evaluador: ${examen.profesorEvaluador}',
      location: examen.salonNombre,
      startDate: examen.fecha,
      endDate: examen.fecha.add(_duracionExamen),
      iosParams: const IOSParams(reminder: Duration(hours: 24)),
      androidParams: const AndroidParams(emailInvites: <String>[]),
    );
  }
}
