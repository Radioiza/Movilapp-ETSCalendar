import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/catalogs/data/datasources/catalogo_local_datasource.dart';
import '../../features/catalogs/data/datasources/catalogo_remote_datasource.dart';
import '../../features/catalogs/data/repositories/catalogo_repository_impl.dart';
import '../../features/catalogs/domain/repositories/catalogo_repository.dart';
import '../../features/exams/data/datasources/examen_local_datasource.dart';
import '../../features/exams/data/datasources/examen_remote_datasource.dart';
import '../../features/exams/data/repositories/examen_repository_impl.dart';
import '../../features/exams/domain/repositories/examen_repository.dart';
import '../../features/exams/domain/usecases/buscar_examenes_usecase.dart';
import '../../features/favorites/data/datasources/favoritos_local_datasource.dart';
import '../../features/favorites/data/repositories/favoritos_repository_impl.dart';
import '../../features/favorites/domain/repositories/favoritos_repository.dart';
import '../../features/favorites/domain/usecases/alternar_favorito_usecase.dart';
import '../../features/favorites/domain/usecases/limpiar_favoritos_usecase.dart';
import '../../features/export/domain/calendario_telefono_service.dart';
import '../../features/notifications/domain/notificacion_service.dart';
import '../local/app_database.dart';
import '../local/seed/sembrador_datos.dart';
import '../network/api_client.dart';

/// Contenedor de inyección de dependencias (`get_it`).
///
/// Desacopla la construcción de servicios, datasources, repositorios y
/// casos de uso de los `widgets`/`providers` que los consumen — tal como lo
/// recomienda el proyecto para mantener el código profesional y testeable.
///
/// Se inicializa una sola vez en `main()` mediante [inicializarDependencias],
/// y los providers de Riverpod (capa de presentación) lo consultan con
/// `sl<Tipo>()` en lugar de instanciar sus dependencias manualmente.
final GetIt sl = GetIt.instance;

Future<void> inicializarDependencias() async {
  // --- Núcleo / infraestructura ---
  sl.registerLazySingleton<ApiClient>(ApiClient.new);
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instancia);
  sl.registerLazySingleton<NotificacionService>(NotificacionService.new);

  final SharedPreferences preferencias = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => preferencias);

  // --- Feature: auth ---
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoto: sl(), local: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  // --- Feature: exams ---
  sl.registerLazySingleton<ExamenRemoteDataSource>(() => ExamenRemoteDataSource(sl()));
  sl.registerLazySingleton<ExamenLocalDataSource>(() => ExamenLocalDataSource(sl()));
  sl.registerLazySingleton<ExamenRepository>(
    () => ExamenRepositoryImpl(remoto: sl(), local: sl()),
  );
  sl.registerLazySingleton<BuscarExamenesUseCase>(() => BuscarExamenesUseCase(sl()));

  // --- Feature: catalogs ---
  sl.registerLazySingleton<CatalogoRemoteDataSource>(() => CatalogoRemoteDataSource(sl()));
  sl.registerLazySingleton<CatalogoLocalDataSource>(() => CatalogoLocalDataSource(sl()));
  sl.registerLazySingleton<CatalogoRepository>(
    () => CatalogoRepositoryImpl(remoto: sl(), local: sl()),
  );

  // --- Feature: favorites ---
  sl.registerLazySingleton<FavoritosLocalDataSource>(() => FavoritosLocalDataSource(sl()));
  sl.registerLazySingleton<FavoritosRepository>(() => FavoritosRepositoryImpl(sl()));
  sl.registerLazySingleton<AlternarFavoritoUseCase>(() => AlternarFavoritoUseCase(sl()));
  sl.registerLazySingleton<LimpiarFavoritosUseCase>(() => LimpiarFavoritosUseCase(sl()));
  sl.registerLazySingleton<CalendarioTelefonoService>(
    () => CalendarioTelefonoService(sl<SharedPreferences>()),
  );

  // --- Siembra de datos (modo demo offline con datos reales de ESCOM) ---
  // Puebla sqflite una sola vez con carreras, salones, exámenes (planes de
  // estudio 2020) y la cuenta administrativa local, para que toda la app sea
  // demostrable sin un backend en línea.
  await SembradorDatos(
    catalogoLocal: sl<CatalogoLocalDataSource>(),
    examenLocal: sl<ExamenLocalDataSource>(),
    authLocal: sl<AuthLocalDataSource>(),
    preferencias: sl<SharedPreferences>(),
  ).sembrarSiHaceFalta();
}
