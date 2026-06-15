import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_datos;
import 'package:timezone/timezone.dart' as tz;

import '../../exams/domain/entities/examen.dart';

/// Resultado de intentar agregar un ETS al calendario del teléfono. Permite a
/// la UI dar un mensaje preciso (y diagnosticar por qué no se guardó).
enum ResultadoCalendario { ok, sinPermiso, sinCalendario, error }

/// Integración con el **calendario nativo del teléfono** (vía `device_calendar`).
///
/// A diferencia de la exportación a `.ics`, este servicio **inserta y elimina**
/// eventos directamente en el calendario del dispositivo. Para poder borrar
/// luego cada ETS, guarda en `shared_preferences` la correspondencia
/// `idExamen -> "calendarId|eventId"` del evento creado.
class CalendarioTelefonoService {
  CalendarioTelefonoService(this._prefs);

  final SharedPreferences _prefs;
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  static const String _llave = 'eventos_telefono';
  static const Duration _duracion = Duration(hours: 2);

  bool _tzListo = false;

  /// Agrega [examen] al calendario del teléfono y recuerda su `eventId` para
  /// poder eliminarlo después. Devuelve el motivo del resultado.
  Future<ResultadoCalendario> agregar(Examen examen) async {
    _asegurarZonaHoraria();
    if (!await _asegurarPermisos()) {
      debugPrint('[Calendario] Permiso de calendario denegado.');
      return ResultadoCalendario.sinPermiso;
    }
    final Calendar? calendario = await _calendarioEscribible();
    if (calendario?.id == null) {
      debugPrint('[Calendario] No se encontró un calendario escribible.');
      return ResultadoCalendario.sinCalendario;
    }
    debugPrint('[Calendario] Escribiendo en "${calendario!.name}" '
        '(${calendario.accountName}/${calendario.accountType}).');

    final Event evento = Event(
      calendario.id,
      title: 'ETS · ${examen.unidadAprendizaje}',
      description: 'Examen a Título de Suficiencia\n'
          'Carrera: ${examen.carreraNombre} (${examen.semestre}.º semestre)\n'
          'Turno: ${examen.turno.etiqueta}\n'
          'Profesor evaluador: ${examen.profesorEvaluador}',
      location: examen.salonNombre,
      start: tz.TZDateTime.from(examen.fecha, tz.local),
      end: tz.TZDateTime.from(examen.fecha.add(_duracion), tz.local),
    );

    final Result<String>? resultado = await _plugin.createOrUpdateEvent(evento);
    final String? eventId = resultado?.data;
    if (resultado == null || !resultado.isSuccess || eventId == null) {
      debugPrint('[Calendario] createOrUpdateEvent falló: '
          '${resultado?.errors.map((ResultError e) => e.errorMessage).join("; ")}');
      return ResultadoCalendario.error;
    }

    final Map<String, String> mapa = _leerMapa();
    mapa[examen.id] = '${calendario.id}|$eventId';
    await _guardarMapa(mapa);
    debugPrint('[Calendario] Evento creado con id $eventId.');
    return ResultadoCalendario.ok;
  }

  /// Quita del calendario del teléfono el evento asociado a [examenId] (si lo
  /// hay) y olvida su referencia.
  Future<void> quitar(String examenId) async {
    final Map<String, String> mapa = _leerMapa();
    final String? referencia = mapa.remove(examenId);
    if (referencia != null) {
      await _eliminarPorReferencia(referencia);
      await _guardarMapa(mapa);
    }
  }

  /// Elimina del teléfono **todos** los eventos de ETS creados por la app y
  /// limpia las referencias guardadas.
  Future<void> limpiarTodo() async {
    final Map<String, String> mapa = _leerMapa();
    for (final String referencia in mapa.values) {
      await _eliminarPorReferencia(referencia);
    }
    await _prefs.remove(_llave);
  }

  // --- Internos -----------------------------------------------------------

  Future<void> _eliminarPorReferencia(String referencia) async {
    final List<String> partes = referencia.split('|');
    if (partes.length != 2) {
      return;
    }
    try {
      await _plugin.deleteEvent(partes[0], partes[1]);
    } on Exception {
      // El usuario pudo haber borrado el evento a mano; se ignora.
    }
  }

  Future<bool> _asegurarPermisos() async {
    final Result<bool> actual = await _plugin.hasPermissions();
    if (actual.isSuccess && (actual.data ?? false)) {
      return true;
    }
    final Result<bool> solicitado = await _plugin.requestPermissions();
    return solicitado.isSuccess && (solicitado.data ?? false);
  }

  Future<Calendar?> _calendarioEscribible() async {
    final resultado = await _plugin.retrieveCalendars();
    final List<Calendar> calendarios = resultado.data?.toList() ?? <Calendar>[];
    debugPrint('[Calendario] ${calendarios.length} calendarios: '
        '${calendarios.map((Calendar c) => '${c.name}/${c.accountType}'
            '/ro=${c.isReadOnly}/def=${c.isDefault}').join(' | ')}');
    if (calendarios.isEmpty) {
      return null;
    }
    bool escribible(Calendar c) => !(c.isReadOnly ?? false);
    bool esGoogle(Calendar c) => c.accountType == 'com.google';
    // Preferir un calendario VISIBLE en la app de Google: cuenta Google +
    // predeterminado; luego cualquiera de Google; luego el predeterminado;
    // por último cualquiera escribible (evita calendarios locales ocultos).
    final List<bool Function(Calendar)> prioridades = <bool Function(Calendar)>[
      (Calendar c) => escribible(c) && esGoogle(c) && (c.isDefault ?? false),
      (Calendar c) => escribible(c) && esGoogle(c),
      (Calendar c) => escribible(c) && (c.isDefault ?? false),
      escribible,
    ];
    for (final bool Function(Calendar) cumple in prioridades) {
      for (final Calendar c in calendarios) {
        if (cumple(c)) {
          return c;
        }
      }
    }
    return null;
  }

  void _asegurarZonaHoraria() {
    if (_tzListo) {
      return;
    }
    tz_datos.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    } on Exception {
      // Si falla, se conserva la zona por defecto (UTC).
    }
    _tzListo = true;
  }

  Map<String, String> _leerMapa() {
    final String? crudo = _prefs.getString(_llave);
    if (crudo == null || crudo.isEmpty) {
      return <String, String>{};
    }
    try {
      final Map<String, dynamic> decodificado = jsonDecode(crudo) as Map<String, dynamic>;
      return decodificado.map((String k, dynamic v) => MapEntry<String, String>(k, v as String));
    } on FormatException {
      return <String, String>{};
    }
  }

  Future<void> _guardarMapa(Map<String, String> mapa) =>
      _prefs.setString(_llave, jsonEncode(mapa));
}
