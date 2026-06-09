import '../entities/usuario.dart';

/// Contrato de la capa de dominio para la autenticación del Módulo
/// Administrativo. La implementación concreta valida credenciales contra
/// las contraseñas encriptadas (ver `PasswordHasher`) y conserva la sesión.
abstract interface class AuthRepository {
  /// Intenta iniciar sesión. Lanza [CredencialesFailure] si no coinciden.
  Future<Usuario> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  });

  Future<void> cerrarSesion();

  /// Recupera la sesión persistida (si existe) al abrir la app.
  Future<Usuario?> obtenerSesionActual();
}
