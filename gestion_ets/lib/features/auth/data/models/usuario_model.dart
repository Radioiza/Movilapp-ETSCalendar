import '../../domain/entities/usuario.dart';

/// Modelo de datos del usuario administrativo: extiende la entidad de
/// dominio agregando el campo sensible [contrasenaEncriptada] (formato
/// `sal:hash`, ver `PasswordHasher`) que **nunca** debe exponerse fuera de
/// la capa de datos / autenticación.
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombreUsuario,
    required super.nombreCompleto,
    required super.rol,
    required this.contrasenaEncriptada,
  });

  /// Hash `sal:hash` generado por [PasswordHasher.encriptar].
  final String contrasenaEncriptada;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'].toString(),
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      nombreCompleto: json['nombreCompleto'] as String? ?? '',
      rol: _rolDesdeTexto(json['rol'] as String?),
      contrasenaEncriptada: json['contrasenaEncriptada'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombreUsuario': nombreUsuario,
      'nombreCompleto': nombreCompleto,
      'rol': rol.name,
      'contrasenaEncriptada': contrasenaEncriptada,
    };
  }

  Usuario aEntidad() {
    return Usuario(
      id: id,
      nombreUsuario: nombreUsuario,
      nombreCompleto: nombreCompleto,
      rol: rol,
    );
  }

  static RolUsuario _rolDesdeTexto(String? valor) {
    return RolUsuario.values.firstWhere(
      (RolUsuario rol) => rol.name == valor,
      orElse: () => RolUsuario.capturista,
    );
  }
}
