import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../exams/domain/entities/examen.dart';
import '../../../exams/presentation/providers/examen_admin_provider.dart';
import '../../domain/estadisticas_dashboard.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/barra_estadistica.dart';

/// **Panel de Control (Dashboard)**: estadísticas rápidas de la oferta de
/// exámenes, p. ej. cuántos hay programados por carrera.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EstadisticasDashboard> estadisticas = ref.watch(estadisticasDashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(examenesAdminProvider.future),
      child: estadisticas.when(
        loading: () => const LoadingView(mensaje: 'Calculando estadísticas…'),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible calcular las estadísticas',
          onReintentar: () => ref.invalidate(examenesAdminProvider),
        ),
        data: (EstadisticasDashboard datos) => _Contenido(datos: datos),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.datos});

  final EstadisticasDashboard datos;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final int maximoCarrera = datos.examenesPorCarrera.isEmpty
        ? 0
        : datos.examenesPorCarrera.map((ConteoPorEtiqueta c) => c.total).reduce((int a, int b) => a > b ? a : b);
    final int maximoTurno = datos.examenesPorTurno.isEmpty
        ? 0
        : datos.examenesPorTurno.map((ConteoPorEtiqueta c) => c.total).reduce((int a, int b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _tarjetaResumen(
                context,
                icono: Icons.event_note_rounded,
                etiqueta: 'Exámenes programados',
                valor: '${datos.totalExamenes}',
                color: esquema.primaryContainer,
                colorTexto: esquema.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tarjetaResumen(
                context,
                icono: Icons.upcoming_rounded,
                etiqueta: 'Próximos exámenes',
                valor: '${datos.proximosExamenes.length}',
                color: esquema.tertiaryContainer,
                colorTexto: esquema.onTertiaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _tarjetaSeccion(
          context,
          titulo: 'Exámenes programados por carrera',
          contenido: datos.examenesPorCarrera.isEmpty
              ? const Text('Aún no hay exámenes registrados')
              : Column(
                  children: datos.examenesPorCarrera
                      .map((ConteoPorEtiqueta c) =>
                          BarraEstadistica(conteo: c, maximo: maximoCarrera, color: esquema.primary))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _tarjetaSeccion(
          context,
          titulo: 'Exámenes programados por turno',
          contenido: datos.examenesPorTurno.isEmpty
              ? const Text('Aún no hay exámenes registrados')
              : Column(
                  children: datos.examenesPorTurno
                      .map((ConteoPorEtiqueta c) =>
                          BarraEstadistica(conteo: c, maximo: maximoTurno, color: esquema.tertiary))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _tarjetaSeccion(
          context,
          titulo: 'Próximos exámenes',
          contenido: datos.proximosExamenes.isEmpty
              ? const Text('No hay exámenes próximos por aplicarse')
              : Column(
                  children: datos.proximosExamenes
                      .map((Examen examen) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: esquema.secondaryContainer,
                              child: Text(examen.fecha.day.toString()),
                            ),
                            title: Text(examen.unidadAprendizaje),
                            subtitle: Text(
                              '${DateFormatter.fechaCorta(examen.fecha)} · ${examen.turno.etiqueta} · ${examen.salonNombre}',
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _tarjetaResumen(
    BuildContext context, {
    required IconData icono,
    required String etiqueta,
    required String valor,
    required Color color,
    required Color colorTexto,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icono, color: colorTexto),
            const SizedBox(height: 12),
            Text(valor, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorTexto)),
            Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorTexto)),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaSeccion(BuildContext context, {required String titulo, required Widget contenido}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }
}
