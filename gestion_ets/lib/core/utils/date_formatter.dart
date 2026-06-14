import 'package:intl/intl.dart';

/// Formateadores de fecha/hora reutilizados en toda la app (tablas,
/// formularios, exportaciones e ICS). Centralizar el formato evita
/// inconsistencias entre pantallas.
abstract final class DateFormatter {
  static final DateFormat _fechaCorta = DateFormat('dd/MM/yyyy', 'es_MX');
  static final DateFormat _fechaLarga = DateFormat('EEEE d \'de\' MMMM \'de\' y', 'es_MX');
  static final DateFormat _hora = DateFormat('HH:mm', 'es_MX');
  static final DateFormat _mesAnio = DateFormat('MMMM \'de\' y', 'es_MX');
  static final DateFormat _mesCorto = DateFormat('MMM', 'es_MX');
  static final DateFormat _fechaHoraIso = DateFormat("yyyyMMdd'T'HHmmss");

  static String fechaCorta(DateTime fecha) => _fechaCorta.format(fecha);

  /// Abreviatura del mes en mayúsculas (p. ej. "JUN") para las tarjetas de
  /// fecha tipo calendario.
  static String mesCorto(DateTime fecha) =>
      _mesCorto.format(fecha).replaceAll('.', '').toUpperCase();

  static String fechaLarga(DateTime fecha) => _fechaLarga.format(fecha);

  static String hora(DateTime fecha) => _hora.format(fecha);

  /// Encabezado del calendario mensual, p. ej. "Junio de 2026" (con la
  /// inicial en mayúscula, que `intl` deja en minúscula para el español).
  static String mesAnio(DateTime fecha) {
    final String texto = _mesAnio.format(fecha);
    return texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  /// Formato `yyyyMMddTHHmmss` requerido por el estándar iCalendar (.ics).
  static String fechaHoraParaIcs(DateTime fecha) => _fechaHoraIso.format(fecha);

  static DateTime? intentarParsear(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor);
  }
}
