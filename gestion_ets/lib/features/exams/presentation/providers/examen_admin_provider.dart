import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/examen.dart';
import '../../domain/repositories/examen_repository.dart';

part 'examen_admin_provider.g.dart';

/// `Notifier` que respalda el **CRUD completo de la oferta de exámenes**
/// del Módulo Administrativo (Altas, Bajas, Cambios y Consultas).
///
/// Cada operación de escritura reconstruye la lista a partir del repositorio
/// para que la tabla administrativa, el buscador público y el dashboard
/// permanezcan consistentes entre sí.
@riverpod
class ExamenesAdmin extends _$ExamenesAdmin {
  ExamenRepository get _repositorio => sl<ExamenRepository>();

  @override
  FutureOr<List<Examen>> build() {
    return _repositorio.obtenerTodos();
  }

  Future<void> crear(Examen examen) => _ejecutarYRefrescar(() => _repositorio.crear(examen));

  Future<void> actualizar(Examen examen) =>
      _ejecutarYRefrescar(() => _repositorio.actualizar(examen));

  Future<void> eliminar(String id) =>
      _ejecutarYRefrescar(() => _repositorio.eliminar(id));

  /// Ejecuta una mutación conservando la lista anterior visible mientras
  /// se procesa y, si falla, también al mostrar el error — así la tabla no
  /// desaparece y la UI puede notificar el problema con un Snackbar sin
  /// perder el contenido ya cargado (`AsyncValue.copyWithPrevious`).
  Future<void> _ejecutarYRefrescar(Future<void> Function() operacion) async {
    final AsyncValue<List<Examen>> anterior = state;
    state = const AsyncValue<List<Examen>>.loading().copyWithPrevious(anterior);
    try {
      await operacion();
      state = AsyncValue<List<Examen>>.data(await _repositorio.obtenerTodos());
    } on Object catch (error, trazado) {
      state = AsyncValue<List<Examen>>.error(error, trazado).copyWithPrevious(anterior);
    }
  }
}
