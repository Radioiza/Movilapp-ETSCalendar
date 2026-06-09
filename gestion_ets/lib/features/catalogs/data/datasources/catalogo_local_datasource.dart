import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/local/app_database.dart';
import '../models/carrera_model.dart';
import '../models/salon_model.dart';

/// Caché local (sqflite) de los catálogos de **Carreras** y
/// **Edificios/Salones**, necesaria para que el buscador y los formularios
/// administrativos funcionen sin conexión.
class CatalogoLocalDataSource {
  const CatalogoLocalDataSource(this._bd);

  final AppDatabase _bd;

  Future<List<CarreraModel>> obtenerCarreras() async {
    try {
      final Database db = await _bd.bd;
      final List<Map<String, dynamic>> filas = await db.query(
        AppConstants.tableCarreras,
        orderBy: 'nombre ASC',
      );
      return filas
          .map((Map<String, dynamic> f) => CarreraModel(
                id: f['id'] as String,
                clave: f['clave'] as String,
                nombre: f['nombre'] as String,
              ))
          .toList();
    } on DatabaseException {
      throw const CacheException('No fue posible leer el catálogo de carreras');
    }
  }

  Future<void> reemplazarCarreras(List<CarreraModel> carreras) async {
    try {
      await _bd.reemplazarTabla(
        AppConstants.tableCarreras,
        carreras.map((CarreraModel c) => c.toJson()).toList(),
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar el catálogo de carreras');
    }
  }

  Future<void> guardarCarrera(CarreraModel carrera) async {
    try {
      final Database db = await _bd.bd;
      await db.insert(
        AppConstants.tableCarreras,
        carrera.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar la carrera');
    }
  }

  Future<void> eliminarCarrera(String id) async {
    try {
      final Database db = await _bd.bd;
      await db.delete(AppConstants.tableCarreras, where: 'id = ?', whereArgs: <Object?>[id]);
    } on DatabaseException {
      throw const CacheException('No fue posible eliminar la carrera guardada');
    }
  }

  Future<List<SalonModel>> obtenerSalones() async {
    try {
      final Database db = await _bd.bd;
      final List<Map<String, dynamic>> filas = await db.query(
        AppConstants.tableSalones,
        orderBy: 'edificio ASC, nombre ASC',
      );
      return filas
          .map((Map<String, dynamic> f) => SalonModel(
                id: f['id'] as String,
                nombre: f['nombre'] as String,
                edificio: f['edificio'] as String,
                direccionMapa: f['direccion_mapa'] as String?,
              ))
          .toList();
    } on DatabaseException {
      throw const CacheException('No fue posible leer el catálogo de salones');
    }
  }

  Future<void> reemplazarSalones(List<SalonModel> salones) async {
    try {
      await _bd.reemplazarTabla(
        AppConstants.tableSalones,
        salones
            .map((SalonModel s) => <String, dynamic>{
                  'id': s.id,
                  'nombre': s.nombre,
                  'edificio': s.edificio,
                  'direccion_mapa': s.direccionMapa,
                })
            .toList(),
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar el catálogo de salones');
    }
  }

  Future<void> guardarSalon(SalonModel salon) async {
    try {
      final Database db = await _bd.bd;
      await db.insert(
        AppConstants.tableSalones,
        <String, dynamic>{
          'id': salon.id,
          'nombre': salon.nombre,
          'edificio': salon.edificio,
          'direccion_mapa': salon.direccionMapa,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar el salón');
    }
  }

  Future<void> eliminarSalon(String id) async {
    try {
      final Database db = await _bd.bd;
      await db.delete(AppConstants.tableSalones, where: 'id = ?', whereArgs: <Object?>[id]);
    } on DatabaseException {
      throw const CacheException('No fue posible eliminar el salón guardado');
    }
  }
}
