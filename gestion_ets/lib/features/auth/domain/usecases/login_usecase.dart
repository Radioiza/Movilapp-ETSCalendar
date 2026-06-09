import '../../../../core/error/failures.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: inicio de sesión del Módulo Administrativo.
///
/// Concentra la regla de negocio de validación de entrada (campos no vacíos)
/// antes de delegar al repositorio, que es quien compara contra la
/// contraseña encriptada almacenada.
class LoginUseCase {
  const LoginUseCase(this._repositorio);

  final AuthRepository _repositorio;

  Future<Usuario> ejecutar({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    final String usuario = nombreUsuario.trim();
    if (usuario.isEmpty || contrasena.isEmpty) {
      throw const ValidacionFailure('Captura tu usuario y contraseña');
    }
    if (contrasena.length < 6) {
      throw const ValidacionFailure('La contraseña debe tener al menos 6 caracteres');
    }
    return _repositorio.iniciarSesion(nombreUsuario: usuario, contrasena: contrasena);
  }
}
