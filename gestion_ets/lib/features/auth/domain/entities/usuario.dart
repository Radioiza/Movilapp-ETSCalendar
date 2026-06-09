/// Rol del usuario administrativo dentro del sistema.
enum RolUsuario {
  administrador,
  capturista;

  String get etiqueta => switch (this) {
        RolUsuario.administrador => 'Administrador',
        RolUsuario.capturista => 'Capturista',
      };
}

/// Entidad de dominio: usuario del módulo administrativo autenticado.
///
/// Nunca contiene la contraseña (ni siquiera encriptada): ese dato
/// pertenece exclusivamente a la capa de datos / autenticación.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  final String id;
  final String nombreUsuario;
  final String nombreCompleto;
  final RolUsuario rol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Usuario && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Usuario($nombreUsuario · ${rol.etiqueta})';
}
