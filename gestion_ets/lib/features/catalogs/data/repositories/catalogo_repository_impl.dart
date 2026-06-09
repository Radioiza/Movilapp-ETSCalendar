import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/carrera.dart';
import '../../domain/entities/salon.dart';
import '../../domain/repositories/catalogo_repository.dart';
import '../datasources/catalogo_local_datasource.dart';
import '../datasources/catalogo_remote_datasource.dart';
import '../models/carrera_model.dart';
import '../models/salon_model.dart';

/// Implementación *offline-first* de [CatalogoRepository]: las operaciones
/// de escritura (alta/edición/baja) requieren backend disponible — son
/// responsabilidad exclusiva del Módulo Administrativo — y, una vez
/// confirmadas, se reflejan en la caché local para que el buscador público
/// pueda seguir consultándolas sin conexión.
class CatalogoRepositoryImpl implements CatalogoRepository {
  const CatalogoRepositoryImpl({
    required CatalogoRemoteDataSource remoto,
    required CatalogoLocalDataSource local,
  })  : _remoto = remoto,
        _local = local;

  final CatalogoRemoteDataSource _remoto;
  final CatalogoLocalDataSource _local;

  @override
  Future<List<Carrera>> obtenerCarreras() async {
    try {
      final List<CarreraModel> remotas = await _remoto.obtenerCarreras();
      await _local.reemplazarCarreras(remotas);
      return remotas;
    } on Exception {
      try {
        return await _local.obtenerCarreras();
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  @override
  Future<Carrera> crearCarrera(Carrera carrera) async {
    final CarreraModel modelo = CarreraModel.desdeEntidad(carrera);
    try {
      final CarreraModel creada = await _remoto.crearCarrera(modelo);
      await _local.guardarCarrera(creada);
      return creada;
    } on Exception {
      // Sin backend disponible: se persiste localmente (modo demo offline).
      return _persistirCarreraLocal(modelo);
    }
  }

  @override
  Future<Carrera> actualizarCarrera(Carrera carrera) async {
    final CarreraModel modelo = CarreraModel.desdeEntidad(carrera);
    try {
      final CarreraModel actualizada = await _remoto.actualizarCarrera(modelo);
      await _local.guardarCarrera(actualizada);
      return actualizada;
    } on Exception {
      return _persistirCarreraLocal(modelo);
    }
  }

  @override
  Future<void> eliminarCarrera(String id) async {
    try {
      await _remoto.eliminarCarrera(id);
      await _local.eliminarCarrera(id);
    } on Exception {
      try {
        await _local.eliminarCarrera(id);
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  Future<Carrera> _persistirCarreraLocal(CarreraModel modelo) async {
    try {
      await _local.guardarCarrera(modelo);
      return modelo;
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<List<Salon>> obtenerSalones() async {
    try {
      final List<SalonModel> remotos = await _remoto.obtenerSalones();
      await _local.reemplazarSalones(remotos);
      return remotos;
    } on Exception {
      try {
        return await _local.obtenerSalones();
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  @override
  Future<Salon> crearSalon(Salon salon) async {
    final SalonModel modelo = SalonModel.desdeEntidad(salon);
    try {
      final SalonModel creado = await _remoto.crearSalon(modelo);
      await _local.guardarSalon(creado);
      return creado;
    } on Exception {
      return _persistirSalonLocal(modelo);
    }
  }

  @override
  Future<Salon> actualizarSalon(Salon salon) async {
    final SalonModel modelo = SalonModel.desdeEntidad(salon);
    try {
      final SalonModel actualizado = await _remoto.actualizarSalon(modelo);
      await _local.guardarSalon(actualizado);
      return actualizado;
    } on Exception {
      return _persistirSalonLocal(modelo);
    }
  }

  @override
  Future<void> eliminarSalon(String id) async {
    try {
      await _remoto.eliminarSalon(id);
      await _local.eliminarSalon(id);
    } on Exception {
      try {
        await _local.eliminarSalon(id);
      } on Exception catch (error) {
        throw mapearAFailure(error);
      }
    }
  }

  Future<Salon> _persistirSalonLocal(SalonModel modelo) async {
    try {
      await _local.guardarSalon(modelo);
      return modelo;
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<void> sincronizar() async {
    try {
      final List<CarreraModel> carreras = await _remoto.obtenerCarreras();
      final List<SalonModel> salones = await _remoto.obtenerSalones();
      await _local.reemplazarCarreras(carreras);
      await _local.reemplazarSalones(salones);
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }
}
