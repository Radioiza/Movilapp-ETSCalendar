import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/local/app_database.dart';
import '../../domain/repositories/examen_repository.dart';
import '../models/examen_model.dart';

/// Fuente de datos local: caché *offline-first* de la oferta de exámenes
/// respaldada por sqflite. Permite que el buscador y el panel administrativo
/// sigan funcionando sin conexión a internet.
class ExamenLocalDataSource {
  const ExamenLocalDataSource(this._bd);

  final AppDatabase _bd;

  Future<List<ExamenModel>> obtenerTodos() async {
    try {
      final Database db = await _bd.bd;
      final List<Map<String, dynamic>> filas = await db.query(
        AppConstants.tableExamenes,
        orderBy: 'fecha ASC',
      );
      return filas.map(ExamenModel.desdeFilaLocal).toList();
    } on DatabaseException {
      throw const CacheException('No fue posible leer la oferta de exámenes guardada');
    }
  }

  Future<List<ExamenModel>> buscar(FiltrosExamen filtros) async {
    try {
      final Database db = await _bd.bd;
      final List<String> condiciones = <String>[];
      final List<Object?> argumentos = <Object?>[];

      if (filtros.carreraId != null) {
        condiciones.add('carrera_id = ?');
        argumentos.add(filtros.carreraId);
      }
      if (filtros.semestre != null) {
        condiciones.add('semestre = ?');
        argumentos.add(filtros.semestre);
      }

      final List<Map<String, dynamic>> filas = await db.query(
        AppConstants.tableExamenes,
        where: condiciones.isEmpty ? null : condiciones.join(' AND '),
        whereArgs: condiciones.isEmpty ? null : argumentos,
        orderBy: 'fecha ASC',
      );

      List<ExamenModel> modelos = filas.map(ExamenModel.desdeFilaLocal).toList();

      // El filtro por materia se aplica aquí (no en SQL) para que sea
      // insensible a acentos y mayúsculas: así "Calculo" encuentra "Cálculo".
      final String? unidad = filtros.unidadAprendizaje?.trim();
      if (unidad != null && unidad.isNotEmpty) {
        final String consulta = _normalizar(unidad);
        modelos = modelos
            .where((ExamenModel e) => _normalizar(e.unidadAprendizaje).contains(consulta))
            .toList();
      }
      return modelos;
    } on DatabaseException {
      throw const CacheException('No fue posible filtrar la oferta de exámenes guardada');
    }
  }

  /// Normaliza un texto para búsquedas tolerantes: minúsculas y sin acentos.
  String _normalizar(String texto) {
    const Map<String, String> equivalencias = <String, String>{
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
      'ñ': 'n',
    };
    final StringBuffer salida = StringBuffer();
    for (final int unidad in texto.toLowerCase().runes) {
      final String caracter = String.fromCharCode(unidad);
      salida.write(equivalencias[caracter] ?? caracter);
    }
    return salida.toString();
  }

  Future<ExamenModel?> obtenerPorId(String id) async {
    try {
      final Database db = await _bd.bd;
      final List<Map<String, dynamic>> filas = await db.query(
        AppConstants.tableExamenes,
        where: 'id = ?',
        whereArgs: <Object?>[id],
        limit: 1,
      );
      if (filas.isEmpty) {
        return null;
      }
      return ExamenModel.desdeFilaLocal(filas.first);
    } on DatabaseException {
      throw const CacheException('No fue posible leer el examen guardado');
    }
  }

  /// Sustituye toda la tabla — usado tras sincronizar con el backend.
  Future<void> reemplazarTodo(List<ExamenModel> examenes) async {
    try {
      await _bd.reemplazarTabla(
        AppConstants.tableExamenes,
        examenes.map((ExamenModel e) => e.aFilaLocal()).toList(),
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar la oferta de exámenes');
    }
  }

  Future<void> guardarUno(ExamenModel examen) async {
    try {
      final Database db = await _bd.bd;
      await db.insert(
        AppConstants.tableExamenes,
        examen.aFilaLocal(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      throw const CacheException('No fue posible guardar el examen');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      final Database db = await _bd.bd;
      await db.delete(
        AppConstants.tableExamenes,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    } on DatabaseException {
      throw const CacheException('No fue posible eliminar el examen guardado');
    }
  }
}
