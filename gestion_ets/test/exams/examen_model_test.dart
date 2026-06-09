import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/features/exams/data/models/examen_model.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';

/// Requerimiento técnico: "modelos robustos con serialización JSON (fromJson)".
/// Se verifica la (de)serialización JSON, el mapeo a/desde la fila local y la
/// tolerancia a campos faltantes/erróneos del backend.
void main() {
  group('ExamenModel.fromJson', () {
    test('parsea un JSON completo del backend', () {
      final ExamenModel modelo = ExamenModel.fromJson(<String, dynamic>{
        'id': 42,
        'unidadAprendizaje': 'Cálculo',
        'carreraId': 'ISC',
        'carreraNombre': 'Ingeniería en Sistemas',
        'semestre': 3,
        'fecha': '2026-07-06T09:00:00.000Z',
        'turno': 'Vespertino',
        'salonId': 's1',
        'salonNombre': 'Edificio 1 · 101',
        'profesorEvaluador': 'Ada Lovelace',
      });

      expect(modelo.id, '42', reason: 'El id numérico debe normalizarse a String');
      expect(modelo.unidadAprendizaje, 'Cálculo');
      expect(modelo.semestre, 3);
      expect(modelo.turno, Turno.vespertino);
    });

    test('tolera campos faltantes con valores por defecto seguros', () {
      final ExamenModel modelo = ExamenModel.fromJson(<String, dynamic>{
        'id': '1',
        'fecha': '2026-07-06T09:00:00.000Z',
      });

      expect(modelo.unidadAprendizaje, '');
      expect(modelo.semestre, 1);
      expect(modelo.turno, Turno.matutino,
          reason: 'Turno desconocido cae en matutino por defecto');
    });
  });

  test('round-trip JSON: toJson -> fromJson preserva los datos', () {
    final ExamenModel original = ExamenModel.fromJson(<String, dynamic>{
      'id': '7',
      'unidadAprendizaje': 'Estructuras de Datos',
      'carreraId': 'ISC',
      'carreraNombre': 'ISC',
      'semestre': 4,
      'fecha': '2026-07-08T16:00:00.000Z',
      'turno': 'Vespertino',
      'salonId': 's2',
      'salonNombre': 'Edificio 2 · 202',
      'profesorEvaluador': 'Alan Turing',
    });

    final ExamenModel reconstruido = ExamenModel.fromJson(original.toJson());

    expect(reconstruido.id, original.id);
    expect(reconstruido.unidadAprendizaje, original.unidadAprendizaje);
    expect(reconstruido.semestre, original.semestre);
    expect(reconstruido.turno, original.turno);
    expect(reconstruido.fecha.toUtc(), original.fecha.toUtc());
  });

  test('round-trip de fila local (sqflite) preserva los datos', () {
    final ExamenModel original = ExamenModel.fromJson(<String, dynamic>{
      'id': '9',
      'unidadAprendizaje': 'Bases de Datos',
      'carreraId': 'ISC',
      'carreraNombre': 'ISC',
      'semestre': 5,
      'fecha': '2026-07-09T09:00:00.000Z',
      'turno': 'Matutino',
      'salonId': 's3',
      'salonNombre': 'Edificio 3 · 303',
      'profesorEvaluador': 'Edgar Codd',
    });

    final ExamenModel desdeFila =
        ExamenModel.desdeFilaLocal(original.aFilaLocal());

    expect(desdeFila.id, '9');
    expect(desdeFila.unidadAprendizaje, 'Bases de Datos');
    expect(desdeFila.turno, Turno.matutino);
    expect(desdeFila.fecha.toUtc(), original.fecha.toUtc());
  });
}
