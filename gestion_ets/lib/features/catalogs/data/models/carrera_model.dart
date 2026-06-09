import '../../domain/entities/carrera.dart';

/// Modelo de datos de [Carrera]: añade serialización JSON (`fromJson`/`toJson`)
/// requerida para consumir la API REST y para la caché local en sqflite.
class CarreraModel extends Carrera {
  const CarreraModel({
    required super.id,
    required super.clave,
    required super.nombre,
  });

  factory CarreraModel.fromJson(Map<String, dynamic> json) {
    return CarreraModel(
      id: json['id'].toString(),
      clave: json['clave'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
    );
  }

  factory CarreraModel.desdeEntidad(Carrera carrera) {
    return CarreraModel(id: carrera.id, clave: carrera.clave, nombre: carrera.nombre);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'clave': clave,
      'nombre': nombre,
    };
  }
}
