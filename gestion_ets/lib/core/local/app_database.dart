import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// Punto único de acceso a la base de datos local **sqflite**.
///
/// Es la pieza central de la estrategia *offline-first*: toda la oferta de
/// exámenes y los catálogos (Carreras, Salones) se reflejan aquí para que la
/// app funcione con conectividad limitada o nula.
class AppDatabase {
  AppDatabase._interna();

  static final AppDatabase instancia = AppDatabase._interna();

  Database? _bd;

  Future<Database> get bd async {
    final Database? actual = _bd;
    if (actual != null) {
      return actual;
    }
    final Database creada = await _abrir();
    _bd = creada;
    return creada;
  }

  Future<Database> _abrir() async {
    final String rutaBase = await getDatabasesPath();
    final String ruta = p.join(rutaBase, AppConstants.databaseName);

    return openDatabase(
      ruta,
      version: AppConstants.databaseVersion,
      onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableCarreras} (
            id TEXT PRIMARY KEY,
            clave TEXT NOT NULL,
            nombre TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ${AppConstants.tableSalones} (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            edificio TEXT NOT NULL,
            direccion_mapa TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE ${AppConstants.tableExamenes} (
            id TEXT PRIMARY KEY,
            unidad_aprendizaje TEXT NOT NULL,
            carrera_id TEXT NOT NULL,
            carrera_nombre TEXT NOT NULL,
            semestre INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            turno TEXT NOT NULL,
            salon_id TEXT NOT NULL,
            salon_nombre TEXT NOT NULL,
            profesor_evaluador TEXT NOT NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_examenes_carrera ON ${AppConstants.tableExamenes} (carrera_id)',
        );
        await db.execute(
          'CREATE INDEX idx_examenes_semestre ON ${AppConstants.tableExamenes} (semestre)',
        );
      },
    );
  }

  /// Reemplaza por completo el contenido de [tabla] dentro de una
  /// transacción — usado al sincronizar la caché con el backend.
  Future<void> reemplazarTabla(String tabla, List<Map<String, dynamic>> filas) async {
    final Database basededatos = await bd;
    await basededatos.transaction((Transaction txn) async {
      await txn.delete(tabla);
      for (final Map<String, dynamic> fila in filas) {
        await txn.insert(tabla, fila, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> cerrar() async {
    final Database? actual = _bd;
    if (actual != null) {
      await actual.close();
      _bd = null;
    }
  }
}
