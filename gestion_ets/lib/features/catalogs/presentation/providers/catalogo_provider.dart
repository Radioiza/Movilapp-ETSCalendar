import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/carrera.dart';
import '../../domain/entities/salon.dart';
import '../../domain/repositories/catalogo_repository.dart';

part 'catalogo_provider.g.dart';

CatalogoRepository get _repositorio => sl<CatalogoRepository>();

/// Catálogo de Carreras — consultado por el buscador público (filtros) y
/// administrado (alta/edición/baja) desde el panel administrativo.
@riverpod
class CarrerasCatalogo extends _$CarrerasCatalogo {
  @override
  FutureOr<List<Carrera>> build() => _repositorio.obtenerCarreras();

  Future<void> crear(Carrera carrera) =>
      _mutarYRefrescar(() => _repositorio.crearCarrera(carrera));

  Future<void> actualizar(Carrera carrera) =>
      _mutarYRefrescar(() => _repositorio.actualizarCarrera(carrera));

  Future<void> eliminar(String id) =>
      _mutarYRefrescar(() => _repositorio.eliminarCarrera(id));

  Future<void> _mutarYRefrescar(Future<void> Function() operacion) async {
    final AsyncValue<List<Carrera>> anterior = state;
    state = const AsyncValue<List<Carrera>>.loading().copyWithPrevious(anterior);
    try {
      await operacion();
      state = AsyncValue<List<Carrera>>.data(await _repositorio.obtenerCarreras());
    } on Object catch (error, trazado) {
      state = AsyncValue<List<Carrera>>.error(error, trazado).copyWithPrevious(anterior);
    }
  }
}

/// Catálogo de Edificios/Salones — análogo al de Carreras.
@riverpod
class SalonesCatalogo extends _$SalonesCatalogo {
  @override
  FutureOr<List<Salon>> build() => _repositorio.obtenerSalones();

  Future<void> crear(Salon salon) =>
      _mutarYRefrescar(() => _repositorio.crearSalon(salon));

  Future<void> actualizar(Salon salon) =>
      _mutarYRefrescar(() => _repositorio.actualizarSalon(salon));

  Future<void> eliminar(String id) =>
      _mutarYRefrescar(() => _repositorio.eliminarSalon(id));

  Future<void> _mutarYRefrescar(Future<void> Function() operacion) async {
    final AsyncValue<List<Salon>> anterior = state;
    state = const AsyncValue<List<Salon>>.loading().copyWithPrevious(anterior);
    try {
      await operacion();
      state = AsyncValue<List<Salon>>.data(await _repositorio.obtenerSalones());
    } on Object catch (error, trazado) {
      state = AsyncValue<List<Salon>>.error(error, trazado).copyWithPrevious(anterior);
    }
  }
}
