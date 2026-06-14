import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/marca_ipn.dart';
import '../../../catalogs/domain/entities/carrera.dart';
import '../../../catalogs/presentation/providers/catalogo_provider.dart';
import '../../../export/domain/ics_export_service.dart';
import '../../../export/domain/pdf_export_service.dart';
import '../../domain/entities/examen.dart';
import '../../domain/repositories/examen_repository.dart';
import '../providers/examen_search_provider.dart';
import '../widgets/filtros_busqueda_bar.dart';
import '../widgets/lista_resultados_examenes.dart';
import 'examen_detalle_screen.dart';

/// Pantalla principal de **consulta**: buscar exámenes, ver el resultado y
/// exportar el calendario (PDF / .ics).
class BusquedaScreen extends ConsumerStatefulWidget {
  const BusquedaScreen({super.key});

  @override
  ConsumerState<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends ConsumerState<BusquedaScreen> {
  final ScrollController _scroll = ScrollController();
  bool _mostrarBotonArriba = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alScrollear);
  }

  @override
  void dispose() {
    _scroll.removeListener(_alScrollear);
    _scroll.dispose();
    super.dispose();
  }

  void _alScrollear() {
    final bool mostrar = _scroll.hasClients && _scroll.offset > 400;
    if (mostrar != _mostrarBotonArriba) {
      setState(() => _mostrarBotonArriba = mostrar);
    }
  }

  void _volverArriba() {
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FiltrosExamen filtros = ref.watch(filtrosBusquedaProvider);
    final FiltrosBusqueda notificadorFiltros = ref.read(filtrosBusquedaProvider.notifier);
    final AsyncValue<List<Examen>> resultados = ref.watch(resultadosBusquedaProvider);
    final AsyncValue<List<Carrera>> carrerasAsync = ref.watch(carrerasCatalogoProvider);

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
        titleSpacing: 16,
        title: Row(
          children: <Widget>[
            const MarcaIpn(tamano: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Gestión de ETS'),
                Text(
                  'IPN · ESCOM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Acceso administrativo',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/admin'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: _mostrarBotonArriba
          ? FloatingActionButton.small(
              tooltip: 'Volver arriba',
              onPressed: _volverArriba,
              child: const Icon(Icons.arrow_upward_rounded),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(resultadosBusquedaProvider.notifier).actualizar(),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            FiltrosBusquedaBar(
              filtros: filtros,
              carreras: carrerasAsync.valueOrNull ?? const <Carrera>[],
              onCarreraCambiada: notificadorFiltros.seleccionarCarrera,
              onSemestreCambiado: notificadorFiltros.seleccionarSemestre,
              onUnidadCambiada: notificadorFiltros.escribirUnidadAprendizaje,
              onLimpiar: notificadorFiltros.limpiar,
            ),
            const SizedBox(height: 4),
            _seccionResultados(context, ref, resultados),
          ],
        ),
      ),
    );
  }

  Widget _seccionResultados(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Examen>> resultados,
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
          return _estadoVacio(context);
        }
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: <Widget>[
                  Text(
                    examenes.length == 1 ? '1 examen' : '${examenes.length} exámenes',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  _botonesExportacion(context, examenes),
                ],
              ),
            ),
            ListaResultadosExamenes(
              examenes: examenes,
              onAbrirDetalle: (Examen examen) => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ExamenDetalleScreen(examenId: examen.id)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _estadoVacio(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: Column(
          children: <Widget>[
            Icon(Icons.search_off_rounded, size: 56, color: esquema.outline),
            const SizedBox(height: 14),
            Text(
              'Sin coincidencias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba con otra materia, carrera o semestre.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonesExportacion(BuildContext context, List<Examen> examenes) {
    return Wrap(
      spacing: 6,
      children: <Widget>[
        IconButton.filledTonal(
          tooltip: 'Descargar en PDF',
          icon: const Icon(Icons.picture_as_pdf_outlined),
          onPressed: () => _exportarPdf(context, examenes),
        ),
        IconButton.filledTonal(
          tooltip: 'Compartir calendario (.ics)',
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
    try {
      await IcsExportService.exportarComoArchivo(examenes);
    } on Exception {
      if (context.mounted) {
        mostrarErrorEnSnackbar(
          context,
          const ServerFailure('No fue posible generar el archivo .ics'),
        );
      }
    }
  }
}
