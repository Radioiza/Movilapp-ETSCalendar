import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../exams/domain/entities/examen.dart';
import '../../domain/notificacion_service.dart';

part 'notificacion_provider.g.dart';

/// `Notifier` que coordina el **recordatorio local** de la fecha de examen.
///
/// Traduce la entidad `Examen` (dominio del feature `exams`) al lenguaje
/// genérico que entiende [NotificacionService] (id/título/cuerpo/fecha),
/// evitando acoplar el servicio de notificaciones a otros features.
@riverpod
class RecordatorioExamen extends _$RecordatorioExamen {
  NotificacionService get _servicio => sl<NotificacionService>();

  @override
  FutureOr<void> build() {}

  Future<bool> activar(Examen examen) async {
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> resultado = await AsyncValue.guard(() async {
      await _servicio.solicitarPermisos();
      await _servicio.programar(
        id: NotificacionService.idDesde(examen.id),
        titulo: 'Recordatorio de ETS — ${examen.unidadAprendizaje}',
        cuerpo:
            'Tu examen es el ${_formatear(examen.fecha)} en ${examen.salonNombre} (${examen.turno.etiqueta}).',
        fechaHora: examen.fecha.subtract(AppConstants.anticipacionRecordatorio),
      );
    });
    state = resultado;
    return !resultado.hasError;
  }

  Future<void> cancelar(Examen examen) async {
    await _servicio.cancelar(NotificacionService.idDesde(examen.id));
  }

  String _formatear(DateTime fecha) {
    final String dd = fecha.day.toString().padLeft(2, '0');
    final String mm = fecha.month.toString().padLeft(2, '0');
    final String hh = fecha.hour.toString().padLeft(2, '0');
    final String min = fecha.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${fecha.year} $hh:$min';
  }
}
