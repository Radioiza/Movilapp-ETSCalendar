/// Turno en el que se aplica un examen.
enum Turno {
  matutino('Matutino'),
  vespertino('Vespertino');

  const Turno(this.etiqueta);

  final String etiqueta;

  static Turno desdeTexto(String valor) {
    return Turno.values.firstWhere(
      (Turno t) => t.etiqueta.toLowerCase() == valor.toLowerCase(),
      orElse: () => Turno.matutino,
    );
  }
}

/// Entidad de dominio: un Examen a Título de Suficiencia (ETS).
///
/// Reúne la información que el módulo público debe mostrar en la tabla de
/// resultados (Materia, Fecha, Turno, Salón, Profesor evaluador) y la que
/// el módulo administrativo gestiona mediante el CRUD completo.
class Examen {
  const Examen({
    required this.id,
    required this.unidadAprendizaje,
    required this.carreraId,
    required this.carreraNombre,
    required this.semestre,
    required this.fecha,
    required this.turno,
    required this.salonId,
    required this.salonNombre,
    required this.profesorEvaluador,
  });

  final String id;

  /// "Materia" mostrada en el buscador y la tabla de resultados.
  final String unidadAprendizaje;

  final String carreraId;
  final String carreraNombre;
  final int semestre;
  final DateTime fecha;
  final Turno turno;

  final String salonId;

  /// Nombre completo del salón ("Edificio · Salón"), denormalizado para
  /// poder mostrarse sin consultas adicionales cuando se trabaja offline.
  final String salonNombre;

  final String profesorEvaluador;

  Examen copyWith({
    String? id,
    String? unidadAprendizaje,
    String? carreraId,
    String? carreraNombre,
    int? semestre,
    DateTime? fecha,
    Turno? turno,
    String? salonId,
    String? salonNombre,
    String? profesorEvaluador,
  }) {
    return Examen(
      id: id ?? this.id,
      unidadAprendizaje: unidadAprendizaje ?? this.unidadAprendizaje,
      carreraId: carreraId ?? this.carreraId,
      carreraNombre: carreraNombre ?? this.carreraNombre,
      semestre: semestre ?? this.semestre,
      fecha: fecha ?? this.fecha,
      turno: turno ?? this.turno,
      salonId: salonId ?? this.salonId,
      salonNombre: salonNombre ?? this.salonNombre,
      profesorEvaluador: profesorEvaluador ?? this.profesorEvaluador,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Examen && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Examen($unidadAprendizaje — ${fecha.toIso8601String()})';
}
