import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/local/app_database.dart';
import 'package:gestion_ets/core/network/api_client.dart';
import 'package:gestion_ets/core/error/exceptions.dart';
import 'package:gestion_ets/features/exams/data/datasources/examen_local_datasource.dart';
import 'package:gestion_ets/features/exams/data/datasources/examen_remote_datasource.dart';
import 'package:gestion_ets/features/exams/data/models/examen_model.dart';
import 'package:gestion_ets/features/exams/data/repositories/examen_repository_impl.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';
import 'package:gestion_ets/features/exams/domain/repositories/examen_repository.dart';

import '../helpers/datos_prueba.dart';

/// Caché local en memoria: reemplaza sqflite para probar el CRUD del
/// repositorio sin base de datos nativa.
class _LocalEnMemoria extends ExamenLocalDataSource {
  _LocalEnMemoria() : super(AppDatabase.instancia);

  final Map<String, ExamenModel> _store = <String, ExamenModel>{};

  @override
  Future<List<ExamenModel>> obtenerTodos() async => _store.values.toList();

  @override
  Future<ExamenModel?> obtenerPorId(String id) async => _store[id];

  @override
  Future<void> guardarUno(ExamenModel examen) async {
    _store[examen.id] = examen;
  }

  @override
  Future<void> eliminar(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> reemplazarTodo(List<ExamenModel> examenes) async {
    _store
      ..clear()
      ..addEntries(examenes.map((ExamenModel e) => MapEntry<String, ExamenModel>(e.id, e)));
  }
}

/// Remoto "sin backend": fuerza el camino offline (persistencia local).
class _RemotoSinBackend extends ExamenRemoteDataSource {
  _RemotoSinBackend() : super(ApiClient());

  @override
  Future<List<ExamenModel>> obtenerExamenes() async =>
      throw const NoConnectionException();
  @override
  Future<ExamenModel> crear(ExamenModel examen) async =>
      throw const NoConnectionException();
  @override
  Future<ExamenModel> actualizar(ExamenModel examen) async =>
      throw const NoConnectionException();
  @override
  Future<void> eliminar(String id) async => throw const NoConnectionException();
}

/// Módulo Administrativo · CRUD Completo: Altas, Bajas, Cambios y Consultas de
/// la oferta de exámenes. Se prueba el flujo offline-first del repositorio.
void main() {
  late _LocalEnMemoria local;
  late ExamenRepository repo;

  setUp(() {
    local = _LocalEnMemoria();
    repo = ExamenRepositoryImpl(remoto: _RemotoSinBackend(), local: local);
  });

  test('Alta: crea y persiste localmente cuando no hay backend', () async {
    final Examen nuevo = examenDePrueba(id: 'n1', unidadAprendizaje: 'Cálculo');

    final Examen creado = await repo.crear(nuevo);

    expect(creado.id, 'n1');
    expect((await local.obtenerPorId('n1'))?.unidadAprendizaje, 'Cálculo');
  });

  test('Cambio: actualiza un examen existente', () async {
    await repo.crear(examenDePrueba(id: 'n1', unidadAprendizaje: 'Cálculo'));

    await repo.actualizar(
      examenDePrueba(id: 'n1', unidadAprendizaje: 'Cálculo Vectorial'),
    );

    expect((await local.obtenerPorId('n1'))?.unidadAprendizaje,
        'Cálculo Vectorial');
  });

  test('Baja: elimina el examen de la caché', () async {
    await repo.crear(examenDePrueba(id: 'n1'));
    await repo.eliminar('n1');
    expect(await local.obtenerPorId('n1'), isNull);
  });

  test('Consulta: obtenerTodos recurre a la caché cuando el remoto falla',
      () async {
    await repo.crear(examenDePrueba(id: 'n1'));
    await repo.crear(examenDePrueba(id: 'n2'));

    final List<Examen> todos = await repo.obtenerTodos();
    expect(todos.map((Examen e) => e.id).toSet(), <String>{'n1', 'n2'});
  });

  test('obtenerPorId de un id inexistente lanza un Failure', () async {
    expect(() => repo.obtenerPorId('no-existe'), throwsA(isA<Exception>()));
  });
}
