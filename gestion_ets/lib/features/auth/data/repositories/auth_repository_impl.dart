import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

/// Implementación *offline-first* de [AuthRepository]: intenta validar las
/// credenciales contra el backend (que resguarda las contraseñas
/// encriptadas) y, si no hay conexión, recurre al respaldo local encriptado
/// con `PasswordHasher` para que el Módulo Administrativo siga siendo
/// accesible sin internet.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoto,
    required AuthLocalDataSource local,
  })  : _remoto = remoto,
        _local = local;

  final AuthRemoteDataSource _remoto;
  final AuthLocalDataSource _local;

  @override
  Future<Usuario> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    try {
      final UsuarioModel usuario = await _remoto.iniciarSesion(
        nombreUsuario: nombreUsuario,
        contrasena: contrasena,
      );
      await _local.guardarSesion(usuario);
      await _local.respaldarCredencial(usuario, contrasena);
      return usuario.aEntidad();
    } on CredencialesInvalidasException catch (error) {
      throw mapearAFailure(error);
    } on Exception {
      return _iniciarSesionConRespaldoLocal(nombreUsuario, contrasena);
    }
  }

  Future<Usuario> _iniciarSesionConRespaldoLocal(
    String nombreUsuario,
    String contrasena,
  ) async {
    try {
      final bool valido = await _local.validarCredencialRespaldo(nombreUsuario, contrasena);
      if (!valido) {
        throw const CredencialesFailure();
      }
      final UsuarioModel? perfil =
          await _local.obtenerPerfilRespaldo() ?? await _local.obtenerSesion();
      if (perfil == null) {
        throw const SinConexionFailure(
          'Sin conexión: inicia sesión una vez con internet para continuar sin conexión',
        );
      }
      await _local.guardarSesion(perfil);
      return perfil.aEntidad();
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _local.cerrarSesion();
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }

  @override
  Future<Usuario?> obtenerSesionActual() async {
    try {
      final UsuarioModel? sesion = await _local.obtenerSesion();
      return sesion?.aEntidad();
    } on Exception catch (error) {
      throw mapearAFailure(error);
    }
  }
}
