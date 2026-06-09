/// Entidad de dominio: una carrera de ESCOM (catálogo administrable).
class Carrera {
  const Carrera({
    required this.id,
    required this.clave,
    required this.nombre,
  });

  final String id;

  /// Clave corta de la carrera, p. ej. "ISC", "LCD", "IIA".
  final String clave;

  final String nombre;

  Carrera copyWith({String? id, String? clave, String? nombre}) {
    return Carrera(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Carrera &&
          other.id == id &&
          other.clave == clave &&
          other.nombre == nombre);

  @override
  int get hashCode => Object.hash(id, clave, nombre);

  @override
  String toString() => 'Carrera($clave — $nombre)';
}
