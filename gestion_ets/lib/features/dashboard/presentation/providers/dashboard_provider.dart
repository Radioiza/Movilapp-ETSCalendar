import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../exams/domain/entities/examen.dart';
import '../../../exams/presentation/providers/examen_admin_provider.dart';
import '../../domain/estadisticas_dashboard.dart';

part 'dashboard_provider.g.dart';

/// Estadísticas del **Panel de Control** administrativo.
///
/// Se deriva (`ref.watch`) de la lista de exámenes administrada por
/// [ExamenesAdmin]: cualquier alta/baja/cambio se refleja aquí de forma
/// reactiva, sin volver a consultar al backend.
@riverpod
Future<EstadisticasDashboard> estadisticasDashboard(Ref ref) async {
  final List<Examen> examenes = await ref.watch(examenesAdminProvider.future);
  return EstadisticasDashboard.calcular(examenes);
}
