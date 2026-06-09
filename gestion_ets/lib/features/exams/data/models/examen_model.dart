import '../../domain/entities/examen.dart';

/// Modelo de datos de [Examen]: añade serialización JSON robusta
/// (`fromJson`/`toJson`) para el consumo del backend REST y mapeos hacia/desde
/// la fila plana usada por la caché local en sqflite (offline-first).
class ExamenModel extends Examen {
  const ExamenModel({
    required super.id,
    required super.unidadAprendizaje,
    required super.carreraId,
    required super.carreraNombre,
    required super.semestre,
    required super.fecha,
    required super.turno,
    required super.salonId,
    required super.salonNombre,
    required super.profesorEvaluador,
  });

  /// Construye el modelo a partir del JSON devuelto por el backend.
  factory ExamenModel.fromJson(Map<String, dynamic> json) {
    return ExamenModel(
      id: json['id'].toString(),
      unidadAprendizaje: json['unidadAprendizaje'] as String? ?? '',
      carreraId: json['carreraId']?.toString() ?? '',
      carreraNombre: json['carreraNombre'] as String? ?? '',
      semestre: (json['semestre'] as num?)?.toInt() ?? 1,
      fecha: DateTime.parse(json['fecha'] as String).toLocal(),
      turno: Turno.desdeTexto(json['turno'] as String? ?? Turno.matutino.etiqueta),
      salonId: json['salonId']?.toString() ?? '',
      salonNombre: json['salonNombre'] as String? ?? '',
      profesorEvaluador: json['profesorEvaluador'] as String? ?? '',
    );
  }

  /// Serializa el examen para enviarlo al backend (alta/edición).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'unidadAprendizaje': unidadAprendizaje,
      'carreraId': carreraId,
      'carreraNombre': carreraNombre,
      'semestre': semestre,
      'fecha': fecha.toUtc().toIso8601String(),
      'turno': turno.etiqueta,
      'salonId': salonId,
      'salonNombre': salonNombre,
      'profesorEvaluador': profesorEvaluador,
    };
  }

  /// Fila plana para la tabla `examenes` de sqflite (caché offline-first).
  Map<String, dynamic> aFilaLocal() {
    return <String, dynamic>{
      'id': id,
      'unidad_aprendizaje': unidadAprendizaje,
      'carrera_id': carreraId,
      'carrera_nombre': carreraNombre,
      'semestre': semestre,
      'fecha': fecha.toUtc().toIso8601String(),
      'turno': turno.etiqueta,
      'salon_id': salonId,
      'salon_nombre': salonNombre,
      'profesor_evaluador': profesorEvaluador,
    };
  }

  factory ExamenModel.desdeFilaLocal(Map<String, dynamic> fila) {
    return ExamenModel(
      id: fila['id'] as String,
      unidadAprendizaje: fila['unidad_aprendizaje'] as String,
      carreraId: fila['carrera_id'] as String,
      carreraNombre: fila['carrera_nombre'] as String,
      semestre: fila['semestre'] as int,
      fecha: DateTime.parse(fila['fecha'] as String).toLocal(),
      turno: Turno.desdeTexto(fila['turno'] as String),
      salonId: fila['salon_id'] as String,
      salonNombre: fila['salon_nombre'] as String,
      profesorEvaluador: fila['profesor_evaluador'] as String,
    );
  }

  factory ExamenModel.desdeEntidad(Examen examen) {
    return ExamenModel(
      id: examen.id,
      unidadAprendizaje: examen.unidadAprendizaje,
      carreraId: examen.carreraId,
      carreraNombre: examen.carreraNombre,
      semestre: examen.semestre,
      fecha: examen.fecha,
      turno: examen.turno,
      salonId: examen.salonId,
      salonNombre: examen.salonNombre,
      profesorEvaluador: examen.profesorEvaluador,
    );
  }
}
