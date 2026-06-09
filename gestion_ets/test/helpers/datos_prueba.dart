import 'package:gestion_ets/features/exams/domain/entities/examen.dart';

/// Construye un [Examen] de prueba con valores por defecto razonables.
/// Cada parámetro puede sobrescribirse para cubrir el caso bajo prueba.
Examen examenDePrueba({
  String id = 'e1',
  String unidadAprendizaje = 'Cálculo',
  String carreraId = 'ISC',
  String carreraNombre = 'Ingeniería en Sistemas Computacionales',
  int semestre = 1,
  DateTime? fecha,
  Turno turno = Turno.matutino,
  String salonId = 's1',
  String salonNombre = 'Edificio 1 · 101',
  String profesorEvaluador = 'M. en C. Ada Lovelace',
}) {
  return Examen(
    id: id,
    unidadAprendizaje: unidadAprendizaje,
    carreraId: carreraId,
    carreraNombre: carreraNombre,
    semestre: semestre,
    fecha: fecha ?? DateTime(2026, 7, 6, 9),
    turno: turno,
    salonId: salonId,
    salonNombre: salonNombre,
    profesorEvaluador: profesorEvaluador,
  );
}
