import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/models/usuario_model.dart';
import '../../../features/auth/domain/entities/usuario.dart';
import '../../../features/catalogs/data/datasources/catalogo_local_datasource.dart';
import '../../../features/catalogs/data/models/carrera_model.dart';
import '../../../features/catalogs/data/models/salon_model.dart';
import '../../../features/exams/data/datasources/examen_local_datasource.dart';
import '../../../features/exams/data/models/examen_model.dart';
import '../../../features/exams/domain/entities/examen.dart';
import '../../constants/app_constants.dart';
import 'datos_semilla_escom.dart';

/// Siembra la base de datos local con datos reales de **ESCOM** la primera vez
/// que se ejecuta la app (modo *demo offline*), de modo que el buscador, la
/// tabla, el dashboard, el CRUD y el login administrativo sean demostrables
/// sin un backend en línea.
///
/// La siembra es idempotente: solo se ejecuta cuando la versión sembrada en
/// `SharedPreferences` no coincide con [AppConstants.versionSemilla], por lo
/// que los cambios que el usuario haga después (altas/bajas) no se pierden al
/// reiniciar la app.
class SembradorDatos {
  const SembradorDatos({
    required CatalogoLocalDataSource catalogoLocal,
    required ExamenLocalDataSource examenLocal,
    required AuthLocalDataSource authLocal,
    required SharedPreferences preferencias,
  })  : _catalogoLocal = catalogoLocal,
        _examenLocal = examenLocal,
        _authLocal = authLocal,
        _prefs = preferencias;

  final CatalogoLocalDataSource _catalogoLocal;
  final ExamenLocalDataSource _examenLocal;
  final AuthLocalDataSource _authLocal;
  final SharedPreferences _prefs;

  Future<void> sembrarSiHaceFalta() async {
    final String? versionActual = _prefs.getString(AppConstants.prefVersionSemilla);
    if (versionActual == AppConstants.versionSemilla) {
      return;
    }

    await _catalogoLocal.reemplazarCarreras(DatosSemillaEscom.carreras);
    await _catalogoLocal.reemplazarSalones(DatosSemillaEscom.salones);
    // La oferta real (jul 6–10) más un ETS de prueba para mañana, útil para
    // demostrar el recordatorio: su aviso (24 h antes) cae unos minutos después
    // de instalar. Va aquí y no en `generarExamenes()` para no afectar las
    // pruebas, que validan la semana oficial.
    final List<ExamenModel> examenes = <ExamenModel>[
      ...generarExamenes(),
      _examenDePruebaRecordatorio(),
    ];
    await _examenLocal.reemplazarTodo(examenes);
    await _sembrarAdministradorLocal();

    await _prefs.setString(
      AppConstants.prefVersionSemilla,
      AppConstants.versionSemilla,
    );
  }

  /// ETS de prueba para **demostrar el recordatorio**. Su fecha es mañana, a
  /// unos minutos por encima de la hora actual, de modo que el aviso (que se
  /// programa 24 h antes) caiga ~4 min después de instalar y se pueda ver la
  /// notificación durante la revisión. Es fácil de identificar y se puede
  /// borrar desde el módulo administrativo.
  ExamenModel _examenDePruebaRecordatorio() {
    final DateTime objetivo = DateTime.now().add(const Duration(hours: 24, minutes: 4));
    final DateTime fecha =
        DateTime(objetivo.year, objetivo.month, objetivo.day, objetivo.hour, objetivo.minute);
    return ExamenModel(
      id: 'prueba-recordatorio',
      unidadAprendizaje: 'ETS de prueba (recordatorio)',
      carreraId: 'isc',
      carreraNombre: 'Ingeniería en Sistemas Computacionales',
      semestre: 1,
      fecha: fecha,
      turno: fecha.hour < 13 ? Turno.matutino : Turno.vespertino,
      salonId: 's-1002',
      salonNombre: 'Edificio 1 · Salón 002',
      profesorEvaluador: 'Demostración de recordatorio',
    );
  }

  /// Crea una cuenta administrativa local (offline) para poder demostrar el
  /// Módulo Administrativo sin backend: usuario `admin` / contraseña `admin123`.
  Future<void> _sembrarAdministradorLocal() async {
    const UsuarioModel admin = UsuarioModel(
      id: 'admin-local',
      nombreUsuario: AppConstants.adminDemoUsuario,
      nombreCompleto: 'Administrador ESCOM',
      rol: RolUsuario.administrador,
      contrasenaEncriptada: '',
    );
    await _authLocal.respaldarCredencial(admin, AppConstants.adminDemoContrasena);
  }

  /// Horas de inicio disponibles para los ETS. Cada examen dura **2 horas** y
  /// puede aplicarse en cualquier bloque entre las **7:00 y las 20:00**, con una
  /// pausa al mediodía (13:00–14:00). Tener varios bloques por turno permite que
  /// un mismo salón atienda varias materias el mismo día (en distintos bloques)
  /// sin traslapes, de modo que toda la oferta cabe en la semana oficial de ETS.
  static const List<int> _horasMatutino = <int>[7, 9, 11]; // 7-9, 9-11, 11-13
  static const List<int> _horasVespertino = <int>[14, 16, 18]; // 14-16, 16-18, 18-20

  /// Semana oficial de ETS: 5 días hábiles desde el lunes 6 de julio de 2026
  /// (lun 6 – vie 10). La oferta nunca se programa fuera de este rango.
  static final DateTime _inicioEts = DateTime(2026, 7, 6);
  static const int _diasEts = 5;

  /// Genera los ETS de la semana oficial (lun 6 – vie 10 de julio de 2026),
  /// asignando a cada materia el **laboratorio o aula que le corresponde según
  /// su área** y **evitando traslapes**: en un mismo salón, día y hora no se
  /// aplican dos exámenes. Cada materia se ofrece en ambos turnos (matutino y
  /// vespertino) el mismo día y salón, en su bloque de 2 horas asignado.
  ///
  /// Es estática y pura (solo depende de [DatosSemillaEscom]) para poder
  /// verificar en pruebas que la asignación de salones por área es correcta y
  /// que no hay traslapes de horario.
  @visibleForTesting
  static List<ExamenModel> generarExamenes() {
    // 1) Materias en orden determinista (con su índice en el semestre, que da
    //    el id estable) y su área.
    final List<_MateriaProgramada> items = <_MateriaProgramada>[];
    for (final CarreraModel carrera in DatosSemillaEscom.carreras) {
      final Map<int, List<String>> plan =
          DatosSemillaEscom.planesEstudio[carrera.id] ?? const <int, List<String>>{};
      final List<int> semestres = plan.keys.toList()..sort();
      for (final int semestre in semestres) {
        final List<String> materias = plan[semestre] ?? const <String>[];
        for (int i = 0; i < materias.length; i++) {
          items.add(_MateriaProgramada(
            carrera: carrera,
            semestre: semestre,
            indiceEnSemestre: i,
            materia: materias[i],
            area: DatosSemillaEscom.areaDe(materias[i]),
          ));
        }
      }
    }

    // 2) La semana oficial de ETS son 5 días hábiles desde el 6 de julio.
    final Map<AreaEts, List<SalonModel>> pools = DatosSemillaEscom.salonesPorArea;
    final List<DateTime> fechas = _diasHabiles(_inicioEts, _diasEts);
    final int bloquesPorTurno = _horasMatutino.length;

    // 3) Asignación sin traslapes. A la j-ésima materia de un área se le da una
    //    terna única (bloque, salón, día): bloque = j % bloques; y con
    //    posición = j ~/ bloques se recorre primero el salón y luego el día.
    //    Como cada (día, salón) ofrece `bloques` huecos y los bloques de un
    //    turno están separados 2 h (y el vespertino empieza tras la comida),
    //    dos materias del mismo salón y día caen en horas distintas y la misma
    //    materia no se traslapa entre sus turnos. Las áreas usan salones
    //    disjuntos, así que tampoco hay traslapes entre áreas.
    final List<ExamenModel> examenes = <ExamenModel>[];
    final Map<AreaEts, int> indiceArea = <AreaEts, int>{};
    for (final _MateriaProgramada it in items) {
      final List<SalonModel> pool = pools[it.area]!;
      final int p = pool.length;
      final int j = indiceArea[it.area] ?? 0;
      indiceArea[it.area] = j + 1;

      final int bloque = j % bloquesPorTurno;
      final int posicion = j ~/ bloquesPorTurno;
      final SalonModel salon = pool[posicion % p];
      final int dia = (posicion ~/ p) % _diasEts;
      final DateTime fecha = fechas[dia];
      final String profesor = DatosSemillaEscom.profesoresPorMateria[it.materia] ??
          DatosSemillaEscom.profesores[j % DatosSemillaEscom.profesores.length];

      for (final Turno turno in Turno.values) {
        final int hora =
            turno == Turno.matutino ? _horasMatutino[bloque] : _horasVespertino[bloque];
        examenes.add(
          ExamenModel(
            id: '${it.carrera.id}-s${it.semestre}-${it.indiceEnSemestre}-${turno.name}',
            unidadAprendizaje: it.materia,
            carreraId: it.carrera.id,
            carreraNombre: it.carrera.nombre,
            semestre: it.semestre,
            fecha: DateTime(fecha.year, fecha.month, fecha.day, hora, 0),
            turno: turno,
            salonId: salon.id,
            salonNombre: salon.nombreCompleto,
            profesorEvaluador: profesor,
          ),
        );
      }
    }
    return examenes;
  }

  /// Primeros [cantidad] días hábiles (lunes a viernes) desde [inicio].
  static List<DateTime> _diasHabiles(DateTime inicio, int cantidad) {
    final List<DateTime> dias = <DateTime>[];
    DateTime cursor = inicio;
    while (dias.length < cantidad) {
      if (cursor.weekday <= DateTime.friday) {
        dias.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return dias;
  }
}

/// Materia lista para programarse: conserva su origen (carrera/semestre/índice
/// para el id) y el área que define su pool de salones.
class _MateriaProgramada {
  const _MateriaProgramada({
    required this.carrera,
    required this.semestre,
    required this.indiceEnSemestre,
    required this.materia,
    required this.area,
  });

  final CarreraModel carrera;
  final int semestre;
  final int indiceEnSemestre;
  final String materia;
  final AreaEts area;
}
