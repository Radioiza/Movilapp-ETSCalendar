import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/examen.dart';
import '../../domain/repositories/examen_repository.dart';
import '../../domain/usecases/buscar_examenes_usecase.dart';

part 'examen_search_provider.g.dart';

/// Estado de los filtros del **Buscador Inteligente** (Carrera, Semestre y
/// Unidad de Aprendizaje). Mantenerlo en su propio `Notifier` permite que la
/// pantalla de búsqueda y la tabla de resultados reaccionen de forma
/// independiente y reactiva, sin usar `setState`.
@riverpod
class FiltrosBusqueda extends _$FiltrosBusqueda {
  @override
  FiltrosExamen build() => const FiltrosExamen();

  void seleccionarCarrera(String? carreraId) {
    state = state.copyWith(carreraId: carreraId, limpiarCarrera: carreraId == null);
  }

  void seleccionarSemestre(int? semestre) {
    state = state.copyWith(semestre: semestre, limpiarSemestre: semestre == null);
  }

  void escribirUnidadAprendizaje(String texto) {
    state = state.copyWith(unidadAprendizaje: texto);
  }

  void limpiar() => state = const FiltrosExamen();
}

/// Resultados de la búsqueda: se recalculan automáticamente cada vez que
/// cambian los filtros (`ref.watch`), combinando backend remoto y caché
/// local de forma transparente gracias al repositorio offline-first.
@riverpod
class ResultadosBusqueda extends _$ResultadosBusqueda {
  BuscarExamenesUseCase get _buscar => sl<BuscarExamenesUseCase>();

  @override
  FutureOr<List<Examen>> build() {
    final FiltrosExamen filtros = ref.watch(filtrosBusquedaProvider);
    return _buscar.ejecutar(filtros);
  }

  Future<void> actualizar() async {
    final FiltrosExamen filtros = ref.read(filtrosBusquedaProvider);
    state = const AsyncValue<List<Examen>>.loading();
    state = await AsyncValue.guard(() => _buscar.ejecutar(filtros));
  }
}

/// Detalle de un examen específico — usado por la pantalla de detalle /
/// exportación individual y por el flujo de recordatorios.
@riverpod
Future<Examen> examenPorId(Ref ref, String id) {
  return sl<ExamenRepository>().obtenerPorId(id);
}
