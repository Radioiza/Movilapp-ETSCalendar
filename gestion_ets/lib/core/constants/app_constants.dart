/// Constantes globales de la aplicación: backend, base de datos local y
/// llaves de almacenamiento. Centralizarlas evita valores "quemados" dispersos
/// por las distintas capas.
class AppConstants {
  const AppConstants._();

  // --- Backend (API REST) ---
  // URL base del backend que expone la oferta de exámenes, carreras y salones.
  // Sustituir por la URL real del backend del curso antes de compilar a producción.
  static const String apiBaseUrl = 'https://api.gestionets.escom.ipn.mx/v1';

  static const String endpointExamenes = '/examenes';
  static const String endpointCarreras = '/carreras';
  static const String endpointSalones = '/salones';
  static const String endpointLogin = '/auth/login';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // --- Base de datos local (sqflite) — caché offline-first ---
  static const String databaseName = 'gestion_ets.db';
  // v2: agrega la tabla `eventos_agenda` (calendario personal del usuario).
  static const int databaseVersion = 2;

  static const String tableExamenes = 'examenes';
  static const String tableCarreras = 'carreras';
  static const String tableSalones = 'salones';
  static const String tableFavoritos = 'favoritos';
  static const String tableEventosAgenda = 'eventos_agenda';

  // --- Shared Preferences — llaves ---
  static const String prefSesionUsuario = 'sesion_usuario';
  static const String prefUltimaSincronizacion = 'ultima_sincronizacion';
  static const String prefVersionSemilla = 'version_semilla';

  // --- Datos semilla / modo demo offline ---
  // Al cambiar la versión se vuelve a sembrar la base local con los datos de
  // ESCOM (planes de estudio 2020). Credenciales del administrador local para
  // demostrar el Módulo Administrativo sin backend.
  static const String versionSemilla = 'escom-2020-v11';
  static const String adminDemoUsuario = 'admin';
  static const String adminDemoContrasena = 'admin123';

  // --- Notificaciones locales ---
  static const String canalRecordatoriosId = 'recordatorios_ets';
  static const String canalRecordatoriosNombre = 'Recordatorios de ETS';
  static const String canalRecordatoriosDescripcion =
      'Avisos para recordar la fecha de tus Exámenes a Título de Suficiencia';
  static const Duration anticipacionRecordatorio = Duration(hours: 24);

  // --- Catálogos fijos del dominio ---
  static const List<String> turnos = <String>['Matutino', 'Vespertino'];
  static const List<int> semestres = <int>[1, 2, 3, 4, 5, 6, 7, 8];

  // --- Soporte ---
  static const String correoSoporte = 'soporte.ets@escom.ipn.mx';
  static const String telefonoSoporte = '+525500000000';
}
