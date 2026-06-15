import '../repositories/favoritos_repository.dart';

/// Caso de uso: vaciar por completo el calendario del alumno (quitar todos los
/// ETS guardados) y devolver el conjunto resultante (vacío) para refrescar la
/// UI.
class LimpiarFavoritosUseCase {
  const LimpiarFavoritosUseCase(this._repositorio);

  final FavoritosRepository _repositorio;

  Future<Set<String>> ejecutar() async {
    await _repositorio.limpiar();
    return _repositorio.obtenerIds();
  }
}
