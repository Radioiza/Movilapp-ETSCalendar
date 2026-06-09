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
    await _examenLocal.reemplazarTodo(_generarExamenes());
    await _sembrarAdministradorLocal();

    await _prefs.setString(
      AppConstants.prefVersionSemilla,
      AppConstants.versionSemilla,
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

  /// Hora de inicio de cada turno. Los ETS duran **2 horas** (la duración la
  /// aplica la exportación a calendario / .ics).
  static const int _horaMatutino = 9; // 09:00 – 11:00
  static const int _horaVespertino = 16; // 16:00 – 18:00

  /// Genera los exámenes ETS del periodo **6 al 10 de julio de 2026**
  /// (lunes a viernes). Cada unidad de aprendizaje de cada plan de estudios se
  /// ofrece en **ambos turnos** (matutino y vespertino) el mismo día.
  List<ExamenModel> _generarExamenes() {
    final List<ExamenModel> examenes = <ExamenModel>[];
    final List<DateTime> dias = <DateTime>[
      DateTime(2026, 7, 6),
      DateTime(2026, 7, 7),
      DateTime(2026, 7, 8),
      DateTime(2026, 7, 9),
      DateTime(2026, 7, 10),
    ];
    final List<SalonModel> salones = DatosSemillaEscom.salones;
    final List<String> profesores = DatosSemillaEscom.profesores;

    int materiaIndex = 0;
    int slot = 0;
    for (final CarreraModel carrera in DatosSemillaEscom.carreras) {
      final Map<int, List<String>> plan =
          DatosSemillaEscom.planesEstudio[carrera.id] ?? const <int, List<String>>{};
      final List<int> semestres = plan.keys.toList()..sort();

      for (final int semestre in semestres) {
        final List<String> materias = plan[semestre] ?? const <String>[];
        for (int i = 0; i < materias.length; i++) {
          final String materia = materias[i];
          final DateTime dia = dias[materiaIndex % dias.length];
          final String profesor = DatosSemillaEscom.profesoresPorMateria[materia] ??
              profesores[materiaIndex % profesores.length];

          for (final Turno turno in Turno.values) {
            final SalonModel salon = salones[slot % salones.length];
            final int hora = turno == Turno.matutino ? _horaMatutino : _horaVespertino;
            examenes.add(
              ExamenModel(
                id: '${carrera.id}-s$semestre-$i-${turno.name}',
                unidadAprendizaje: materia,
                carreraId: carrera.id,
                carreraNombre: carrera.nombre,
                semestre: semestre,
                fecha: DateTime(dia.year, dia.month, dia.day, hora, 0),
                turno: turno,
                salonId: salon.id,
                salonNombre: salon.nombreCompleto,
                profesorEvaluador: profesor,
              ),
            );
            slot++;
          }
          materiaIndex++;
        }
      }
    }
    return examenes;
  }
}
