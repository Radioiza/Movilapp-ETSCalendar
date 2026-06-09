/// Contrato de la capa de dominio para administrar los **exámenes
/// favoritos/guardados** del usuario (caché local con `shared_preferences`).
///
/// Solo se conservan los identificadores: el detalle del examen se obtiene
/// del [ExamenRepository], que ya mantiene su propia caché offline-first.
abstract interface class FavoritosRepository {
  Future<Set<String>> obtenerIds();

  Future<void> alternar(String examenId);

  Future<bool> esFavorito(String examenId);
}
