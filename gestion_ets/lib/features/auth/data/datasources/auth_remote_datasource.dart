import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/usuario_model.dart';

/// Fuente de datos remota: valida las credenciales contra el backend, que es
/// quien resguarda y compara las contraseñas encriptadas del lado servidor.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._cliente);

  final ApiClient _cliente;

  /// Envía las credenciales al backend (siempre vía HTTPS). El backend
  /// responde con los datos del usuario autenticado si son correctas, o un
  /// 401/403 que [ApiClient] traduce en `CredencialesInvalidasException`.
  Future<UsuarioModel> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    final dynamic respuesta = await _cliente.publicar(
      AppConstants.endpointLogin,
      cuerpo: <String, dynamic>{
        'nombreUsuario': nombreUsuario,
        'contrasena': contrasena,
      },
    );
    return UsuarioModel.fromJson(respuesta as Map<String, dynamic>);
  }
}
