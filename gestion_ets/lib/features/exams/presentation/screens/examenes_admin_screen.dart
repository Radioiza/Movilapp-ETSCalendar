import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/examen.dart';
import '../providers/examen_admin_provider.dart';
import 'examen_form_screen.dart';

/// **CRUD Completo** de la oferta de exámenes (Altas, Bajas, Cambios y
/// Consultas) — núcleo del Módulo Administrativo (Gestión).
class ExamenesAdminScreen extends ConsumerWidget {
  const ExamenesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Examen>> examenes = ref.watch(examenesAdminProvider);

    ref.listen<AsyncValue<List<Examen>>>(examenesAdminProvider, (
      AsyncValue<List<Examen>>? anterior,
      AsyncValue<List<Examen>> actual,
    ) {
      final Object? error = actual.error;
      if (error is Failure && actual.hasValue) {
        mostrarErrorEnSnackbar(context, error);
      }
    });

    return Scaffold(
      body: examenes.when(
        loading: () => const LoadingView(mensaje: 'Cargando oferta de exámenes…'),
        error: (Object error, StackTrace _) => ErrorView(
          mensaje: error is Failure ? error.message : 'No fue posible cargar los exámenes',
          onReintentar: () => ref.invalidate(examenesAdminProvider),
        ),
        data: (List<Examen> lista) => _Listado(examenes: lista),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo examen'),
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context, [Examen? examen]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ExamenFormScreen(examen: examen)),
    );
  }
}

class _Listado extends ConsumerWidget {
  const _Listado({required this.examenes});

  final List<Examen> examenes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (examenes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no hay exámenes registrados.\nUsa el botón "+" para dar de alta el primero.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(examenesAdminProvider.future),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: examenes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int indice) {
          final Examen examen = examenes[indice];
          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(examen.unidadAprendizaje, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          '${examen.carreraNombre} · ${examen.semestre}.º semestre\n'
                          '${DateFormatter.fechaCorta(examen.fecha)} ${DateFormatter.hora(examen.fecha)} h · '
                          '${examen.turno.etiqueta} · ${examen.salonNombre}\n'
                          'Profesor evaluador: ${examen.profesorEvaluador}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => ExamenFormScreen(examen: examen)),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmarEliminar(context, ref, examen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, WidgetRef ref, Examen examen) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog(
        title: const Text('Eliminar examen'),
        content: Text('¿Seguro que deseas eliminar "${examen.unidadAprendizaje}" de la oferta?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(contexto).colorScheme.error),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar ?? false) {
      await ref.read(examenesAdminProvider.notifier).eliminar(examen.id);
    }
  }
}
