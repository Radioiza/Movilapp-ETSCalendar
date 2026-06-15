import '../../../../core/error/error_mapper.dart';
import '../../domain/repositories/favoritos_repository.dart';
import '../datasources/favoritos_local_datasource.dart';

/// Implementación de [FavoritosRepository] sobre `shared_preferences`.
class FavoritosRepositoryImpl implements FavoritosRepository {
  const FavoritosRepositoryImpl(this._local);

  final FavoritosLocalDataSource _local;

  @override
  Future<Set<String>> obtenerIds() async {
    try {
      return await _local.obtenerIds();
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<void> alternar(String examenId) async {
    try {
      final Set<String> actuales = await _local.obtenerIds();
      if (!actuales.remove(examenId)) {
        actuales.add(examenId);
      }
      await _local.guardarIds(actuales);
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<bool> esFavorito(String examenId) async {
    try {
      final Set<String> actuales = await _local.obtenerIds();
      return actuales.contains(examenId);
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<void> limpiar() async {
    try {
      await _local.limpiar();
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }
}
