import '../entities/examen.dart';

/// Filtros del buscador inteligente del módulo público.
/// Todos los campos son opcionales: un valor `null` significa "sin filtrar
/// por este criterio".
class FiltrosExamen {
  const FiltrosExamen({this.carreraId, this.semestre, this.unidadAprendizaje});

  final String? carreraId;
  final int? semestre;
  final String? unidadAprendizaje;

  bool get estaVacio =>
      carreraId == null && semestre == null &&
      (unidadAprendizaje == null || unidadAprendizaje!.trim().isEmpty);

  FiltrosExamen copyWith({
    String? carreraId,
    int? semestre,
    String? unidadAprendizaje,
    bool limpiarCarrera = false,
    bool limpiarSemestre = false,
  }) {
    return FiltrosExamen(
      carreraId: limpiarCarrera ? null : (carreraId ?? this.carreraId),
      semestre: limpiarSemestre ? null : (semestre ?? this.semestre),
      unidadAprendizaje: unidadAprendizaje ?? this.unidadAprendizaje,
    );
  }
}

/// Contrato de la capa de dominio para acceder a la oferta de exámenes.
///
/// La implementación concreta (capa de datos) decide cómo combinar el
/// backend remoto con la caché local de sqflite para ofrecer una
/// experiencia *offline-first*: intenta sincronizar con el servidor y, si no
/// hay conexión, recurre a los datos guardados localmente.
abstract interface class ExamenRepository {
  /// Lista la oferta de exámenes aplicando [filtros] (búsqueda inteligente).
  Future<List<Examen>> buscarExamenes(FiltrosExamen filtros);

  /// Lista completa de exámenes — usada por el panel administrativo.
  Future<List<Examen>> obtenerTodos();

  Future<Examen> obtenerPorId(String id);

  /// Alta de un nuevo examen en la oferta (CRUD administrativo).
  Future<Examen> crear(Examen examen);

  /// Modificación de un examen existente (CRUD administrativo).
  Future<Examen> actualizar(Examen examen);

  /// Baja de un examen de la oferta (CRUD administrativo).
  Future<void> eliminar(String id);

  /// Fuerza la sincronización del backend hacia la caché local.
  Future<void> sincronizar();
}
