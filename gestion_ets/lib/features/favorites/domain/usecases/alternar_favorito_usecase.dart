import '../repositories/favoritos_repository.dart';

/// Caso de uso: marcar/desmarcar un examen como favorito y devolver el
/// conjunto de identificadores actualizado, listo para refrescar la UI.
class AlternarFavoritoUseCase {
  const AlternarFavoritoUseCase(this._repositorio);

  final FavoritosRepository _repositorio;

  Future<Set<String>> ejecutar(String examenId) async {
    await _repositorio.alternar(examenId);
    return _repositorio.obtenerIds();
  }
}
