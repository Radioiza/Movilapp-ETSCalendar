import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/local/app_database.dart';
import 'package:gestion_ets/features/exams/data/datasources/examen_local_datasource.dart';

/// Módulo Público · Buscador Inteligente: la búsqueda por materia debe ser
/// insensible a acentos y mayúsculas ("Calculo" encuentra "Cálculo"). Se prueba
/// el normalizador directamente (no requiere base de datos).
void main() {
  final ExamenLocalDataSource ds = ExamenLocalDataSource(AppDatabase.instancia);

  test('quita acentos y pasa a minúsculas', () {
    expect(ds.normalizarParaBusqueda('Cálculo'), 'calculo');
    expect(ds.normalizarParaBusqueda('PROGRAMACIÓN'), 'programacion');
    expect(ds.normalizarParaBusqueda('Diseño'), 'diseno');
  });

  test('"Calculo" normaliza igual que "Cálculo" (búsqueda tolerante)', () {
    expect(
      ds.normalizarParaBusqueda('Calculo'),
      ds.normalizarParaBusqueda('Cálculo'),
    );
  });

  test('una consulta normalizada es subcadena de la materia normalizada', () {
    final String materia = ds.normalizarParaBusqueda('Análisis y Diseño');
    final String consulta = ds.normalizarParaBusqueda('diseno');
    expect(materia.contains(consulta), isTrue);
  });
}
