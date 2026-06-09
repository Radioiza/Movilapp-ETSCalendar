/// Entidad de dominio: un salón dentro de un edificio (catálogo administrable).
///
/// Incluye una [direccion] de mapas para que el módulo público pueda abrir
/// la ubicación con `url_launcher` (geolocalización del salón).
class Salon {
  const Salon({
    required this.id,
    required this.nombre,
    required this.edificio,
    this.direccionMapa,
  });

  final String id;

  /// Identificador del salón dentro del edificio, p. ej. "CC-301".
  final String nombre;

  /// Edificio al que pertenece, p. ej. "Edificio de Posgrado".
  final String edificio;

  /// URL de mapas (Google Maps) para ubicar el edificio/salón. Puede ser
  /// nulo si el catálogo aún no la captura.
  final String? direccionMapa;

  String get nombreCompleto => '$edificio · $nombre';

  Salon copyWith({
    String? id,
    String? nombre,
    String? edificio,
    String? direccionMapa,
  }) {
    return Salon(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edificio: edificio ?? this.edificio,
      direccionMapa: direccionMapa ?? this.direccionMapa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Salon &&
          other.id == id &&
          other.nombre == nombre &&
          other.edificio == edificio &&
          other.direccionMapa == direccionMapa);

  @override
  int get hashCode => Object.hash(id, nombre, edificio, direccionMapa);

  @override
  String toString() => 'Salon($nombreCompleto)';
}
