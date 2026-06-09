import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/favoritos_repository.dart';
import '../../domain/usecases/alternar_favorito_usecase.dart';

part 'favoritos_provider.g.dart';

/// Conjunto de identificadores de **exámenes favoritos/guardados**,
/// persistido con `shared_preferences` (caché local offline-first).
///
/// Se expone como `Set<String>` para que cualquier tarjeta de examen pueda
/// preguntar `favoritos.contains(examen.id)` sin recorrer listas.
@riverpod
class FavoritosExamenes extends _$FavoritosExamenes {
  FavoritosRepository get _repositorio => sl<FavoritosRepository>();
  AlternarFavoritoUseCase get _alternar => sl<AlternarFavoritoUseCase>();

  @override
  FutureOr<Set<String>> build() => _repositorio.obtenerIds();

  Future<void> alternar(String examenId) async {
    final AsyncValue<Set<String>> anterior = state;
    state = const AsyncValue<Set<String>>.loading().copyWithPrevious(anterior);
    state = await AsyncValue.guard(() => _alternar.ejecutar(examenId));
  }
}
