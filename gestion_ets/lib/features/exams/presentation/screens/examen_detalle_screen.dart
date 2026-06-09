import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../export/domain/ics_export_service.dart';
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
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final AsyncValue<Set<String>> favoritos = ref.watch(favoritosExamenesProvider);
    final bool esFavorito = favoritos.valueOrNull?.contains(examen.id) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        examen.unidadAprendizaje,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: esFavorito ? 'Quitar de guardados' : 'Guardar examen',
                      icon: Icon(
                        esFavorito ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: esFavorito ? esquema.primary : null,
                      ),
                      onPressed: () =>
                          ref.read(favoritosExamenesProvider.notifier).alternar(examen.id),
                    ),
                  ],
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
        _seccionAcciones(context, ref),
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

  Widget _seccionAcciones(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: () => LauncherHelper.abrirUbicacionSalon(
                nombreCompleto: examen.salonNombre,
              ),
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Ubicar salón'),
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
            OutlinedButton.icon(
              onPressed: () => IcsExportService.agregarAlCalendario(examen),
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Agregar a calendario'),
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
