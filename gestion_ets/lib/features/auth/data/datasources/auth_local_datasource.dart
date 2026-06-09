import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/password_hasher.dart';
import '../models/usuario_model.dart';

/// Fuente de datos local de autenticación, respaldada por
/// `shared_preferences`. Cumple dos propósitos:
///
/// 1. Persistir la sesión activa para que el usuario no tenga que volver a
///    iniciar sesión cada vez que abre la app.
/// 2. Guardar una copia *encriptada* (`PasswordHasher`) de las últimas
///    credenciales validadas con éxito, de modo que el Módulo Administrativo
///    siga siendo accesible aun sin conexión (offline-first).
class AuthLocalDataSource {
  const AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _llaveCredencialRespaldo = 'credencial_admin_respaldo';

  Future<void> guardarSesion(UsuarioModel usuario) async {
    try {
      await _prefs.setString(
        AppConstants.prefSesionUsuario,
        jsonEncode(usuario.toJson()),
      );
    } on Exception {
      throw const CacheException('No fue posible guardar tu sesión');
    }
  }

  Future<UsuarioModel?> obtenerSesion() async {
    final String? crudo = _prefs.getString(AppConstants.prefSesionUsuario);
    if (crudo == null) {
      return null;
    }
    try {
      return UsuarioModel.fromJson(jsonDecode(crudo) as Map<String, dynamic>);
    } on FormatException {
      throw const CacheException('La sesión guardada está dañada');
    }
  }

  Future<void> cerrarSesion() async {
    await _prefs.remove(AppConstants.prefSesionUsuario);
  }

  /// Guarda el perfil del usuario + hash de la contraseña validada con éxito,
  /// para permitir el acceso sin conexión (incluida la cuenta administrativa
  /// local del modo demo).
  Future<void> respaldarCredencial(UsuarioModel usuario, String contrasenaPlana) async {
    final Map<String, dynamic> respaldo = <String, dynamic>{
      'nombreUsuario': usuario.nombreUsuario,
      'contrasenaEncriptada': PasswordHasher.encriptar(contrasenaPlana),
      'perfil': usuario.toJson(),
    };
    await _prefs.setString(_llaveCredencialRespaldo, jsonEncode(respaldo));
  }

  /// Valida contra la copia encriptada guardada localmente (sin conexión).
  Future<bool> validarCredencialRespaldo(String nombreUsuario, String contrasenaPlana) async {
    final String? crudo = _prefs.getString(_llaveCredencialRespaldo);
    if (crudo == null) {
      return false;
    }
    final Map<String, dynamic> respaldo = jsonDecode(crudo) as Map<String, dynamic>;
    if (respaldo['nombreUsuario'] != nombreUsuario) {
      return false;
    }
    return PasswordHasher.verificar(
      contrasenaPlana,
      respaldo['contrasenaEncriptada'] as String,
    );
  }

  /// Recupera el perfil asociado a la credencial de respaldo (sin conexión).
  Future<UsuarioModel?> obtenerPerfilRespaldo() async {
    final String? crudo = _prefs.getString(_llaveCredencialRespaldo);
    if (crudo == null) {
      return null;
    }
    try {
      final Map<String, dynamic> respaldo = jsonDecode(crudo) as Map<String, dynamic>;
      final Object? perfil = respaldo['perfil'];
      if (perfil is Map<String, dynamic>) {
        return UsuarioModel.fromJson(perfil);
      }
      return null;
    } on FormatException {
      return null;
    }
  }
}
