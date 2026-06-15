import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../exams/domain/entities/examen.dart';
import '../../../exams/presentation/screens/examen_detalle_screen.dart';
import '../../../exams/presentation/widgets/lista_resultados_examenes.dart';
import '../../../export/domain/calendario_telefono_service.dart';
import '../../../export/domain/ics_export_service.dart';
import '../../../favorites/presentation/providers/favoritos_provider.dart';
import '../../../export/domain/pdf_export_service.dart';
import '../providers/agenda_provider.dart';
import '../widgets/calendario_mensual.dart';

/// **Mi Calendario**: muestra, en un calendario mensual, los ETS que el
/// usuario agregó desde el detalle de cada examen. La navegación se limita al
/// periodo en que el IPN tiene ETS programados y no permite capturar exámenes
/// a mano: el alta se hace buscando el ETS oficial y tocando "Agregar a
/// calendario".
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _mesEnfocado = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _diaSeleccionado = DateTime.now();
  bool _inicializado = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Examen>> examenesAsync = ref.watch(examenesEnCalendarioProvider);
    final RangoEts? rango = ref.watch(rangoEtsProvider).valueOrNull;

    // Al conocer el periodo oficial, centramos el calendario dentro de él una
    // sola vez (sin provocar reconstrucciones en cadena).
    if (!_inicializado && rango != null) {
      _inicializado = true;
      _mesEnfocado = rango.acotar(_mesEnfocado);
      final DateTime hoy = DateTime.now();
      _diaSeleccionado = rango.contieneDia(hoy)
          ? DateTime(hoy.year, hoy.month, hoy.day)
          : rango.primerMes;
    }

    final bool hayExamenes = examenesAsync.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Calendario'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Limpiar mi calendario',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: hayExamenes ? _confirmarLimpiar : null,
          ),
          PopupMenuButton<_ExportarAgenda>(
            tooltip: 'Exportar mis ETS',
            icon: const Icon(Icons.ios_share_rounded),
            onSelected: _exportar,
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<_ExportarAgenda>>[
              PopupMenuItem<_ExportarAgenda>(
                value: _ExportarAgenda.pdf,
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined),
                  title: Text('Exportar mis ETS a PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<_ExportarAgenda>(
                value: _ExportarAgenda.ics,
                child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text('Compartir mis ETS (.ics)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _cuerpo(examenesAsync, rango),
    );
  }

  Widget _cuerpo(AsyncValue<List<Examen>> examenesAsync, RangoEts? rango) {
    if (examenesAsync.isLoading && !examenesAsync.hasValue) {
      return const LoadingView(mensaje: 'Cargando tu calendario…');
    }
    if (examenesAsync.hasError && !examenesAsync.hasValue) {
      final Object? error = examenesAsync.error;
      return ErrorView(
        mensaje: error is Failure ? error.message : 'No fue posible cargar tu calendario',
        onReintentar: () => ref.invalidate(examenesEnCalendarioProvider),
      );
    }
    return _contenido(examenesAsync.valueOrNull ?? const <Examen>[], rango);
  }

  Widget _contenido(List<Examen> examenes, RangoEts? rango) {
    final Map<DateTime, int> conteoPorDia = <DateTime, int>{};
    for (final Examen examen in examenes) {
      final DateTime dia = _normalizar(examen.fecha);
      conteoPorDia[dia] = (conteoPorDia[dia] ?? 0) + 1;
    }

    final List<Examen> delDia = examenes
        .where((Examen examen) => _mismoDia(examen.fecha, _diaSeleccionado))
        .toList();

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: CalendarioMensual(
            mesEnfocado: _mesEnfocado,
            diaSeleccionado: _diaSeleccionado,
            conteoPorDia: conteoPorDia,
            mesMinimo: rango?.primerMes,
            mesMaximo: rango?.ultimoMes,
            onDiaSeleccionado: (DateTime dia) => setState(() => _diaSeleccionado = dia),
            onCambiarMes: (int delta) => setState(() {
              final DateTime nuevo = DateTime(_mesEnfocado.year, _mesEnfocado.month + delta);
              _mesEnfocado = rango?.acotar(nuevo) ?? nuevo;
            }),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              _capitalizar(DateFormatter.fechaLarga(_diaSeleccionado)),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        if (examenes.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _calendarioVacio())
        else if (delDia.isEmpty)
          SliverToBoxAdapter(child: _diaSinEts())
        else
          SliverToBoxAdapter(
            child: ListaResultadosExamenes(
              examenes: delDia,
              onAbrirDetalle: _abrirDetalle,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _calendarioVacio() {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.event_note_outlined, size: 56, color: esquema.outline),
            const SizedBox(height: 14),
            Text('Tu calendario está vacío', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Ve a la pestaña Buscar, abre un ETS y toca '
              '“Agregar a calendario” para verlo aquí.',
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

  Widget _diaSinEts() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Center(
        child: Text(
          'No tienes ETS este día.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  void _abrirDetalle(Examen examen) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExamenDetalleScreen(examenId: examen.id),
    ));
  }

  Future<void> _exportar(_ExportarAgenda formato) async {
    final List<Examen> examenes =
        ref.read(examenesEnCalendarioProvider).valueOrNull ?? const <Examen>[];
    if (examenes.isEmpty) {
      _avisar('Aún no agregas ETS a tu calendario');
      return;
    }
    try {
      switch (formato) {
        case _ExportarAgenda.pdf:
          await PdfExportService.exportarYCompartir(
            examenes: examenes,
            titulo: 'Mi calendario de ETS',
          );
        case _ExportarAgenda.ics:
          await IcsExportService.exportarComoArchivo(examenes);
      }
    } on Exception {
      _avisar('No fue posible exportar tu calendario');
    }
  }

  /// Pide confirmación y, si el alumno acepta, vacía su calendario.
  Future<void> _confirmarLimpiar() async {
    final int total =
        ref.read(examenesEnCalendarioProvider).valueOrNull?.length ?? 0;
    if (total == 0) {
      return;
    }
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const Icon(Icons.delete_sweep_outlined),
        title: const Text('Vaciar mi calendario'),
        content: Text(
          'Se quitarán los $total ETS que agregaste, también del calendario de tu '
          'teléfono. Esto no los borra de la oferta oficial.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirmar ?? false) {
      await _limpiar();
    }
  }

  Future<void> _limpiar() async {
    try {
      // Primero borra los eventos del teléfono (usa las referencias guardadas)
      // y luego vacía el calendario in-app.
      try {
        await sl<CalendarioTelefonoService>().limpiarTodo();
      } on Exception {
        // Si falla el borrado en el teléfono, igual se vacía la app.
      }
      await ref.read(favoritosExamenesProvider.notifier).limpiar();
      _avisar('Tu calendario quedó vacío');
    } on Exception {
      _avisar('No fue posible limpiar tu calendario');
    }
  }

  void _avisar(String mensaje) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String _capitalizar(String texto) =>
      texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';

  static DateTime _normalizar(DateTime fecha) => DateTime(fecha.year, fecha.month, fecha.day);

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Formato de exportación del calendario.
enum _ExportarAgenda { pdf, ics }
