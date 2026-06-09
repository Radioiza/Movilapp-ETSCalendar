import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/examen.dart';
import '../../domain/repositories/examen_repository.dart';
import '../datasources/examen_local_datasource.dart';
import '../datasources/examen_remote_datasource.dart';
import '../models/examen_model.dart';

/// Implementación *offline-first* de [ExamenRepository]: intenta resolver
/// contra el backend remoto y refresca la caché local; si la red falla
/// (sin conexión, timeout, error de servidor) recurre a sqflite para que la
/// app siga siendo utilizable.
class ExamenRepositoryImpl implements ExamenRepository {
  const ExamenRepositoryImpl({
    required ExamenRemoteDataSource remoto,
    required ExamenLocalDataSource local,
  })  : _remoto = remoto,
        _local = local;

  final ExamenRemoteDataSource _remoto;
  final ExamenLocalDataSource _local;

  @override
  Future<List<Examen>> buscarExamenes(FiltrosExamen filtros) async {
    try {
      await sincronizar();
    } on Failure {
      // Sin conexión o backend caído: se continúa con la caché local.
    }
    try {
      return await _local.buscar(filtros);
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<List<Examen>> obtenerTodos() async {
    try {
      final List<ExamenModel> remotos = await _remoto.obtenerExamenes();
      await _local.reemplazarTodo(remotos);
      return remotos;
    } on Exception {
      try {
        return await _local.obtenerTodos();
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  @override
  Future<Examen> obtenerPorId(String id) async {
    try {
      final ExamenModel? local = await _local.obtenerPorId(id);
      if (local != null) {
        return local;
      }
      throw const NotFoundException('No se encontró el examen solicitado');
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<Examen> crear(Examen examen) async {
    final ExamenModel modelo = ExamenModel.desdeEntidad(examen);
    try {
      final ExamenModel creado = await _remoto.crear(modelo);
      await _local.guardarUno(creado);
      return creado;
    } on Exception {
      // Sin backend disponible: se persiste localmente (modo demo offline).
      return _persistirLocal(modelo);
    }
  }

  @override
  Future<Examen> actualizar(Examen examen) async {
    final ExamenModel modelo = ExamenModel.desdeEntidad(examen);
    try {
      final ExamenModel actualizado = await _remoto.actualizar(modelo);
      await _local.guardarUno(actualizado);
      return actualizado;
    } on Exception {
      return _persistirLocal(modelo);
    }
  }

  @override
  Future<void> eliminar(String id) async {
    try {
      await _remoto.eliminar(id);
      await _local.eliminar(id);
    } on Exception {
      try {
        await _local.eliminar(id);
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  Future<Examen> _persistirLocal(ExamenModel modelo) async {
    try {
      await _local.guardarUno(modelo);
      return modelo;
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<void> sincronizar() async {
    try {
      final List<ExamenModel> remotos = await _remoto.obtenerExamenes();
      await _local.reemplazarTodo(remotos);
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }
}
