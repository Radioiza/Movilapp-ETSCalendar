import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../agenda/presentation/providers/agenda_provider.dart';
import '../../../export/domain/calendario_telefono_service.dart';
import '../../../export/domain/pdf_export_service.dart';
import '../../../favorites/presentation/providers/favoritos_provider.dart';
import '../../../notifications/presentation/providers/notificacion_provider.dart';
import '../../domain/entities/examen.dart';
import '../providers/examen_search_provider.dart';

/// Detalle de un examen: información completa, accesos directos a
/// **interoperabilidad** (ubicación del salón / contacto con soporte vía
/// `url_launcher`), **notificaciones locales** (recordatorio) y
/// **exportación** individual (PDF / .ics), además de favoritos.
class ExamenDetalleScreen extends ConsumerWidget {
  const ExamenDetalleScreen({super.key, required this.examenId});

  final String examenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Examen> examenAsync = ref.watch(examenPorIdProvider(examenId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del examen')),
      body: examenAsync.when(
        loading: () => const LoadingView(mensaje: 'Cargando examen…'),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar el examen',
          onReintentar: () => ref.invalidate(examenPorIdProvider(examenId)),
        ),
        data: (Examen examen) => _Contenido(examen: examen),
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.examen});

  final Examen examen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Set<String>> enCalendario = ref.watch(favoritosExamenesProvider);
    final bool esEnCalendario = enCalendario.valueOrNull?.contains(examen.id) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  examen.unidadAprendizaje,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${examen.carreraNombre} · ${examen.semestre}.º semestre',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(height: 32),
                _filaInfo(context, Icons.event_rounded, 'Fecha',
                    DateFormatter.fechaLarga(examen.fecha)),
                _filaInfo(context, Icons.schedule_rounded, 'Hora',
                    '${DateFormatter.hora(examen.fecha)} h · ${examen.turno.etiqueta}'),
                _filaInfo(context, Icons.meeting_room_rounded, 'Salón', examen.salonNombre),
                _filaInfo(context, Icons.person_rounded, 'Profesor evaluador',
                    examen.profesorEvaluador),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _seccionAcciones(context, ref, esEnCalendario),
      ],
    );
  }

  Widget _filaInfo(BuildContext context, IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icono, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(etiqueta, style: Theme.of(context).textTheme.labelMedium),
                Text(valor, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionAcciones(BuildContext context, WidgetRef ref, bool esEnCalendario) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (esEnCalendario)
              OutlinedButton.icon(
                onPressed: () => _quitarDelCalendario(context, ref),
                icon: const Icon(Icons.event_busy_outlined),
                label: const Text('Quitar de mi calendario'),
              )
            else
              FilledButton.icon(
                onPressed: () => _agregarAlCalendario(context, ref),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Agregar a calendario'),
              ),
            FilledButton.tonalIcon(
              onPressed: () => _activarRecordatorio(context, ref),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Recordarme'),
            ),
            OutlinedButton.icon(
              onPressed: () => PdfExportService.exportarYCompartir(examenes: <Examen>[examen]),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
            TextButton.icon(
              onPressed: () => LauncherHelper.enviarCorreoSoporte(
                asunto: 'Duda sobre mi ETS de ${examen.unidadAprendizaje}',
              ),
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Contactar a soporte'),
            ),
          ],
        ),
      ),
    );
  }

  /// Duración estándar de un ETS; se usa para detectar traslapes de horario en
  /// el calendario del alumno (coincide con la usada al exportar a .ics).
  static const Duration _duracionExamen = Duration(hours: 2);

  /// Agrega el examen a **mi calendario** (la app) y, además, lo manda al
  /// **calendario del teléfono**. Antes de agregar, avisa si el ETS **se
  /// traslapa** con otro que el alumno ya tenga o si **ya agregó esa misma
  /// materia** en otro horario, dándole la opción de continuar o cancelar.
  Future<void> _agregarAlCalendario(BuildContext context, WidgetRef ref) async {
    final List<Examen> agregados =
        await ref.read(examenesEnCalendarioProvider.future);

    final DateTime inicio = examen.fecha;
    final DateTime fin = examen.fecha.add(_duracionExamen);
    final List<Examen> traslapes = <Examen>[];
    final List<Examen> mismaMateria = <Examen>[];
    for (final Examen otro in agregados) {
      if (otro.id == examen.id) {
        continue;
      }
      final bool seTraslapan =
          inicio.isBefore(otro.fecha.add(_duracionExamen)) && otro.fecha.isBefore(fin);
      if (seTraslapan) {
        traslapes.add(otro);
      }
      if (otro.unidadAprendizaje == examen.unidadAprendizaje) {
        mismaMateria.add(otro);
      }
    }

    if (!context.mounted) {
      return;
    }
    if (traslapes.isNotEmpty || mismaMateria.isNotEmpty) {
      final bool continuar = await _confirmarConflicto(context, traslapes, mismaMateria);
      if (!continuar || !context.mounted) {
        return;
      }
    }

    await ref.read(favoritosExamenesProvider.notifier).alternar(examen.id);

    ResultadoCalendario telefono;
    try {
      telefono = await sl<CalendarioTelefonoService>().agregar(examen);
    } on Exception {
      telefono = ResultadoCalendario.error;
    }
    if (!context.mounted) {
      return;
    }
    final String mensaje;
    switch (telefono) {
      case ResultadoCalendario.ok:
        mensaje = 'Agregado a tu calendario y al del teléfono';
      case ResultadoCalendario.sinPermiso:
        mensaje = 'Agregado a la app. Concede el permiso de Calendario para '
            'guardarlo también en el teléfono.';
      case ResultadoCalendario.sinCalendario:
        mensaje = 'Agregado a la app. No se encontró un calendario en el teléfono '
            'donde escribir; usa “PDF” o el “.ics”.';
      case ResultadoCalendario.error:
        mensaje = 'Agregado a la app. No se pudo escribir en el calendario del '
            'teléfono; usa “PDF” o el “.ics”.';
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Diálogo que enumera los conflictos detectados (traslapes y/o misma
  /// materia) y deja al alumno decidir si agrega el ETS de todos modos.
  Future<bool> _confirmarConflicto(
    BuildContext context,
    List<Examen> traslapes,
    List<Examen> mismaMateria,
  ) async {
    String linea(Examen e) =>
        '${DateFormatter.fechaCorta(e.fecha)} · ${DateFormatter.hora(e.fecha)} h '
        '(${e.turno.etiqueta})';

    final StringBuffer mensaje = StringBuffer();
    if (traslapes.isNotEmpty) {
      mensaje.writeln('Se traslapa en horario con:');
      for (final Examen e in traslapes) {
        mensaje.writeln('•  ${e.unidadAprendizaje}\n   ${linea(e)}');
      }
    }
    if (mismaMateria.isNotEmpty) {
      if (mensaje.isNotEmpty) {
        mensaje.writeln();
      }
      mensaje.writeln('Ya agregaste esta materia en otro horario:');
      for (final Examen e in mismaMateria) {
        mensaje.writeln('•  ${linea(e)}');
      }
    }

    final bool? continuar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Posible conflicto'),
        content: SingleChildScrollView(
          child: Text(mensaje.toString().trimRight()),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Agregar de todos modos'),
          ),
        ],
      ),
    );
    return continuar ?? false;
  }

  Future<void> _quitarDelCalendario(BuildContext context, WidgetRef ref) async {
    await ref.read(favoritosExamenesProvider.notifier).alternar(examen.id);
    try {
      await sl<CalendarioTelefonoService>().quitar(examen.id);
    } on Exception {
      // Si no se pudo borrar del teléfono, igual se quitó de la app.
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Quitado de tu calendario y del teléfono')));
  }

  Future<void> _activarRecordatorio(BuildContext context, WidgetRef ref) async {
    final bool exito = await ref.read(recordatorioExamenProvider.notifier).activar(examen);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(exito
            ? 'Te avisaremos un día antes de tu examen'
            : 'No fue posible programar el recordatorio'),
      ));
  }
}
