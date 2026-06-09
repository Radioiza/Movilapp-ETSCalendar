import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/error/failures.dart';
import 'package:gestion_ets/core/error/exceptions.dart';
import 'package:gestion_ets/core/network/api_client.dart';
import 'package:gestion_ets/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:gestion_ets/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gestion_ets/features/auth/data/models/usuario_model.dart';
import 'package:gestion_ets/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gestion_ets/features/auth/domain/entities/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remoto que simula "sin backend": lanza siempre una excepción de red,
/// forzando el camino offline-first (respaldo local encriptado).
class _RemotoSinConexion extends AuthRemoteDataSource {
  _RemotoSinConexion() : super(ApiClient());

  @override
  Future<UsuarioModel> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    throw const NoConnectionException();
  }
}

/// Verifica el inicio de sesión del administrador en **modo demo offline**
/// (Módulo Administrativo · Autenticación) tal como queda sembrado por
/// `SembradorDatos`: usuario `admin` / contraseña `admin123` encriptada.
void main() {
  late AuthRepositoryImpl repo;
  late AuthLocalDataSource local;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    local = AuthLocalDataSource(prefs);

    // Reproduce el sembrado de la credencial administrativa local.
    const UsuarioModel admin = UsuarioModel(
      id: 'admin-local',
      nombreUsuario: 'admin',
      nombreCompleto: 'Administrador ESCOM',
      rol: RolUsuario.administrador,
      contrasenaEncriptada: '',
    );
    await local.respaldarCredencial(admin, 'admin123');

    repo = AuthRepositoryImpl(remoto: _RemotoSinConexion(), local: local);
  });

  test('admin/admin123 inicia sesión vía respaldo local sin conexión',
      () async {
    final Usuario usuario = await repo.iniciarSesion(
      nombreUsuario: 'admin',
      contrasena: 'admin123',
    );

    expect(usuario.nombreUsuario, 'admin');
    expect(usuario.rol, RolUsuario.administrador);
  });

  test('contraseña incorrecta sin conexión lanza CredencialesFailure',
      () async {
    expect(
      () => repo.iniciarSesion(nombreUsuario: 'admin', contrasena: 'malísima'),
      throwsA(isA<CredencialesFailure>()),
    );
  });

  test('la sesión queda persistida tras un login exitoso', () async {
    await repo.iniciarSesion(nombreUsuario: 'admin', contrasena: 'admin123');
    final Usuario? sesion = await repo.obtenerSesionActual();
    expect(sesion, isNotNull);
    expect(sesion!.nombreUsuario, 'admin');
  });
}
