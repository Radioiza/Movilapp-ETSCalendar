import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../exams/domain/entities/examen.dart';

/// Servicio de **exportación a formato .ics (iCalendar)** — los puntos extra
/// del requerimiento "Exportación" del Módulo Público.
///
/// [exportarComoArchivo] genera un archivo **.ics** estándar (RFC 5545) con los
/// exámenes y abre la hoja de compartir. No depende de que el dispositivo tenga
/// una app de calendario; el archivo es importable en Google Calendar, Outlook,
/// Apple Calendar, etc. (Para escribir/eliminar eventos directamente en el
/// calendario del teléfono, ver `CalendarioTelefonoService`.)
abstract final class IcsExportService {
  static const Duration _duracionExamen = Duration(hours: 2);

  /// Genera un archivo `.ics` con [examenes] y lo comparte con el sistema.
  static Future<void> exportarComoArchivo(List<Examen> examenes) async {
    final String contenido = _construirIcs(examenes);
    final Directory dir = await getTemporaryDirectory();
    final File archivo = File('${dir.path}/calendario_ets.ics');
    await archivo.writeAsString(contenido);

    await Share.shareXFiles(
      <XFile>[XFile(archivo.path, mimeType: 'text/calendar')],
      subject: 'Calendario de ETS',
      text: 'Calendario de Exámenes a Título de Suficiencia '
          '(${examenes.length} examen(es))',
    );
  }

  /// Construye el documento iCalendar (RFC 5545) con un `VEVENT` por examen.
  ///
  /// Expuesto para pruebas: permite validar el contenido generado sin depender
  /// de E/S de archivos ni de la hoja de compartir del sistema.
  @visibleForTesting
  static String construirIcs(List<Examen> examenes) => _construirIcs(examenes);

  static String _construirIcs(List<Examen> examenes) {
    final List<String> lineas = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//ESCOM IPN//Gestion ETS//ES',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
    ];

    final String sello = _fechaIcs(DateTime.now());
    for (final Examen examen in examenes) {
      final DateTime fin = examen.fecha.add(_duracionExamen);
      lineas.addAll(<String>[
        'BEGIN:VEVENT',
        'UID:${examen.id}@gestionets.escom.ipn.mx',
        'DTSTAMP:$sello',
        'DTSTART:${_fechaIcs(examen.fecha)}',
        'DTEND:${_fechaIcs(fin)}',
        'SUMMARY:${_escapar('ETS · ${examen.unidadAprendizaje}')}',
        'LOCATION:${_escapar(examen.salonNombre)}',
        'DESCRIPTION:${_escapar('Examen a Título de Suficiencia\n'
            'Carrera: ${examen.carreraNombre} (${examen.semestre}.º semestre)\n'
            'Turno: ${examen.turno.etiqueta}\n'
            'Profesor evaluador: ${examen.profesorEvaluador}')}',
        'END:VEVENT',
      ]);
    }

    lineas.add('END:VCALENDAR');
    // iCalendar exige terminaciones de línea CRLF.
    return '${lineas.join('\r\n')}\r\n';
  }

  /// Fecha en formato UTC de iCalendar: `YYYYMMDDTHHMMSSZ`.
  static String _fechaIcs(DateTime fecha) {
    final DateTime u = fecha.toUtc();
    String d(int n) => n.toString().padLeft(2, '0');
    return '${u.year}${d(u.month)}${d(u.day)}T${d(u.hour)}${d(u.minute)}${d(u.second)}Z';
  }

  /// Escapa los caracteres especiales de los valores TEXT de iCalendar.
  static String _escapar(String texto) {
    return texto
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}
