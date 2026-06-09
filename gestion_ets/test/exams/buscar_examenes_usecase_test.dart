import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';
import 'package:gestion_ets/features/exams/domain/repositories/examen_repository.dart';
import 'package:gestion_ets/features/exams/domain/usecases/buscar_examenes_usecase.dart';

import '../helpers/datos_prueba.dart';

/// Repositorio falso que devuelve los exámenes en desorden y registra los
/// filtros recibidos, para verificar el contrato del buscador.
class _ExamenRepoFake implements ExamenRepository {
  _ExamenRepoFake(this._resultado);

  final List<Examen> _resultado;
  FiltrosExamen? filtrosRecibidos;

  @override
  Future<List<Examen>> buscarExamenes(FiltrosExamen filtros) async {
    filtrosRecibidos = filtros;
    return _resultado;
  }

  @override
  Future<List<Examen>> obtenerTodos() async => _resultado;
  @override
  Future<Examen> obtenerPorId(String id) async =>
      _resultado.firstWhere((Examen e) => e.id == id);
  @override
  Future<Examen> crear(Examen examen) async => examen;
  @override
  Future<Examen> actualizar(Examen examen) async => examen;
  @override
  Future<void> eliminar(String id) async {}
  @override
  Future<void> sincronizar() async {}
}

/// Módulo Público · Buscador Inteligente: el caso de uso debe ordenar los
/// resultados cronológicamente y pasar los filtros al repositorio.
void main() {
  test('ordena los resultados por fecha ascendente', () async {
    final List<Examen> desordenados = <Examen>[
      examenDePrueba(id: 'c', fecha: DateTime(2026, 7, 10, 9)),
      examenDePrueba(id: 'a', fecha: DateTime(2026, 7, 6, 9)),
      examenDePrueba(id: 'b', fecha: DateTime(2026, 7, 8, 16)),
    ];
    final BuscarExamenesUseCase usecase =
        BuscarExamenesUseCase(_ExamenRepoFake(desordenados));

    final List<Examen> resultado =
        await usecase.ejecutar(const FiltrosExamen());

    expect(resultado.map((Examen e) => e.id).toList(), <String>['a', 'b', 'c']);
  });

  test('pasa los filtros (carrera, semestre, materia) al repositorio',
      () async {
    final _ExamenRepoFake repo = _ExamenRepoFake(<Examen>[]);
    final BuscarExamenesUseCase usecase = BuscarExamenesUseCase(repo);

    await usecase.ejecutar(const FiltrosExamen(
      carreraId: 'ISC',
      semestre: 3,
      unidadAprendizaje: 'cálculo',
    ));

    expect(repo.filtrosRecibidos?.carreraId, 'ISC');
    expect(repo.filtrosRecibidos?.semestre, 3);
    expect(repo.filtrosRecibidos?.unidadAprendizaje, 'cálculo');
  });

  group('FiltrosExamen', () {
    test('estaVacio detecta ausencia de filtros', () {
      expect(const FiltrosExamen().estaVacio, isTrue);
      expect(const FiltrosExamen(unidadAprendizaje: '   ').estaVacio, isTrue);
      expect(const FiltrosExamen(carreraId: 'ISC').estaVacio, isFalse);
      expect(const FiltrosExamen(semestre: 2).estaVacio, isFalse);
    });

    test('copyWith puede limpiar carrera y semestre', () {
      const FiltrosExamen base = FiltrosExamen(carreraId: 'ISC', semestre: 4);
      final FiltrosExamen limpio =
          base.copyWith(limpiarCarrera: true, limpiarSemestre: true);
      expect(limpio.carreraId, isNull);
      expect(limpio.semestre, isNull);
    });
  });
}
