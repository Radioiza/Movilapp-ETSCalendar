import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../catalogs/domain/entities/carrera.dart';
import '../../../catalogs/presentation/providers/catalogo_provider.dart';
import '../../../export/domain/ics_export_service.dart';
import '../../../export/domain/pdf_export_service.dart';
import '../../../favorites/presentation/providers/favoritos_provider.dart';
import '../../domain/entities/examen.dart';
import '../../domain/repositories/examen_repository.dart';
import '../providers/examen_search_provider.dart';
import '../widgets/filtros_busqueda_bar.dart';
import '../widgets/tabla_resultados_examenes.dart';
import 'examen_detalle_screen.dart';

/// Pantalla principal del **Módulo Público (Consulta)**: Buscador
/// Inteligente + Visualización Dinámica + Exportación del calendario.
class BusquedaScreen extends ConsumerWidget {
  const BusquedaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FiltrosExamen filtros = ref.watch(filtrosBusquedaProvider);
    final FiltrosBusqueda notificadorFiltros = ref.read(filtrosBusquedaProvider.notifier);
    final AsyncValue<List<Examen>> resultados = ref.watch(resultadosBusquedaProvider);
    final AsyncValue<List<Carrera>> carrerasAsync = ref.watch(carrerasCatalogoProvider);
    final AsyncValue<Set<String>> favoritos = ref.watch(favoritosExamenesProvider);

    ref.listen<AsyncValue<List<Examen>>>(resultadosBusquedaProvider, (
      AsyncValue<List<Examen>>? anterior,
      AsyncValue<List<Examen>> actual,
    ) {
      final Object? error = actual.error;
      if (error is Failure && actual.hasValue) {
        mostrarErrorEnSnackbar(context, error);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de ETS'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Acceso administrativo',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/admin'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(resultadosBusquedaProvider.notifier).actualizar(),
        child: ListView(
          children: <Widget>[
            FiltrosBusquedaBar(
              filtros: filtros,
              carreras: carrerasAsync.valueOrNull ?? const <Carrera>[],
              onCarreraCambiada: notificadorFiltros.seleccionarCarrera,
              onSemestreCambiado: notificadorFiltros.seleccionarSemestre,
              onUnidadCambiada: notificadorFiltros.escribirUnidadAprendizaje,
              onLimpiar: notificadorFiltros.limpiar,
            ),
            const SizedBox(height: 8),
            _seccionResultados(context, ref, resultados, favoritos),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _seccionResultados(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Examen>> resultados,
    AsyncValue<Set<String>> favoritos,
  ) {
    return resultados.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: LoadingView(mensaje: 'Buscando exámenes…'),
      ),
      error: (Object error, StackTrace _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar los exámenes',
          onReintentar: () => ref.read(resultadosBusquedaProvider.notifier).actualizar(),
        ),
      ),
      data: (List<Examen> examenes) {
        if (examenes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('No se encontraron exámenes con esos criterios de búsqueda'),
            ),
          );
        }
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    '${examenes.length} resultado(s)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  _botonesExportacion(context, examenes),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TablaResultadosExamenes(
              examenes: examenes,
              favoritos: favoritos.valueOrNull ?? const <String>{},
              onAlternarFavorito: (Examen examen) =>
                  ref.read(favoritosExamenesProvider.notifier).alternar(examen.id),
              onAbrirDetalle: (Examen examen) => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ExamenDetalleScreen(examenId: examen.id)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _botonesExportacion(BuildContext context, List<Examen> examenes) {
    return Wrap(
      spacing: 4,
      children: <Widget>[
        IconButton.filledTonal(
          tooltip: 'Exportar a PDF',
          icon: const Icon(Icons.picture_as_pdf_outlined),
          onPressed: () => _exportarPdf(context, examenes),
        ),
        IconButton.filledTonal(
          tooltip: 'Exportar a calendario (.ics)',
          icon: const Icon(Icons.event_available_outlined),
          onPressed: () => _exportarIcs(context, examenes),
        ),
      ],
    );
  }

  Future<void> _exportarPdf(BuildContext context, List<Examen> examenes) async {
    try {
      await PdfExportService.exportarYCompartir(examenes: examenes);
    } on Exception {
      if (context.mounted) {
        mostrarErrorEnSnackbar(context, const ServerFailure('No fue posible generar el PDF'));
      }
    }
  }

  Future<void> _exportarIcs(BuildContext context, List<Examen> examenes) async {
    final int exitosos = await IcsExportService.exportarVarios(examenes);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(exitosos > 0
            ? 'Se agregaron $exitosos examen(es) a tu calendario (.ics)'
            : 'No fue posible exportar al calendario'),
      ));
  }
}
