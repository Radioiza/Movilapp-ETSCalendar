import '../../domain/entities/salon.dart';

/// Modelo de datos de [Salon]: añade serialización JSON (`fromJson`/`toJson`)
/// requerida para consumir la API REST y para la caché local en sqflite.
class SalonModel extends Salon {
  const SalonModel({
    required super.id,
    required super.nombre,
    required super.edificio,
    super.direccionMapa,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'].toString(),
      nombre: json['nombre'] as String? ?? '',
      edificio: json['edificio'] as String? ?? '',
      direccionMapa: json['direccionMapa'] as String?,
    );
  }

  factory SalonModel.desdeEntidad(Salon salon) {
    return SalonModel(
      id: salon.id,
      nombre: salon.nombre,
      edificio: salon.edificio,
      direccionMapa: salon.direccionMapa,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'edificio': edificio,
      'direccionMapa': direccionMapa,
    };
  }
}
