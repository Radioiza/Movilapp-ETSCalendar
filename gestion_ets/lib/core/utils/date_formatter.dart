import 'package:intl/intl.dart';

/// Formateadores de fecha/hora reutilizados en toda la app (tablas,
/// formularios, exportaciones e ICS). Centralizar el formato evita
/// inconsistencias entre pantallas.
abstract final class DateFormatter {
  static final DateFormat _fechaCorta = DateFormat('dd/MM/yyyy', 'es_MX');
  static final DateFormat _fechaLarga = DateFormat('EEEE d \'de\' MMMM \'de\' y', 'es_MX');
  static final DateFormat _hora = DateFormat('HH:mm', 'es_MX');
  static final DateFormat _fechaHoraIso = DateFormat("yyyyMMdd'T'HHmmss");

  static String fechaCorta(DateTime fecha) => _fechaCorta.format(fecha);

  static String fechaLarga(DateTime fecha) => _fechaLarga.format(fecha);

  static String hora(DateTime fecha) => _hora.format(fecha);

  /// Formato `yyyyMMddTHHmmss` requerido por el estándar iCalendar (.ics).
  static String fechaHoraParaIcs(DateTime fecha) => _fechaHoraIso.format(fecha);

  static DateTime? intentarParsear(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor);
  }
}
