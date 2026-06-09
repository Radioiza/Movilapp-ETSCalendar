import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/carrera_model.dart';
import '../models/salon_model.dart';

/// Fuente de datos remota para los catálogos de **Carreras** y
/// **Edificios/Salones** consumidos del backend REST.
class CatalogoRemoteDataSource {
  const CatalogoRemoteDataSource(this._cliente);

  final ApiClient _cliente;

  Future<List<CarreraModel>> obtenerCarreras() async {
    final dynamic respuesta = await _cliente.obtener(AppConstants.endpointCarreras);
    final List<dynamic> lista = respuesta as List<dynamic>;
    return lista
        .map((dynamic json) => CarreraModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CarreraModel> crearCarrera(CarreraModel carrera) async {
    final dynamic respuesta = await _cliente.publicar(
      AppConstants.endpointCarreras,
      cuerpo: carrera.toJson(),
    );
    return CarreraModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<CarreraModel> actualizarCarrera(CarreraModel carrera) async {
    final dynamic respuesta = await _cliente.actualizar(
      '${AppConstants.endpointCarreras}/${carrera.id}',
      cuerpo: carrera.toJson(),
    );
    return CarreraModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<void> eliminarCarrera(String id) {
    return _cliente.eliminar('${AppConstants.endpointCarreras}/$id');
  }

  Future<List<SalonModel>> obtenerSalones() async {
    final dynamic respuesta = await _cliente.obtener(AppConstants.endpointSalones);
    final List<dynamic> lista = respuesta as List<dynamic>;
    return lista
        .map((dynamic json) => SalonModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SalonModel> crearSalon(SalonModel salon) async {
    final dynamic respuesta = await _cliente.publicar(
      AppConstants.endpointSalones,
      cuerpo: salon.toJson(),
    );
    return SalonModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<SalonModel> actualizarSalon(SalonModel salon) async {
    final dynamic respuesta = await _cliente.actualizar(
      '${AppConstants.endpointSalones}/${salon.id}',
      cuerpo: salon.toJson(),
    );
    return SalonModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<void> eliminarSalon(String id) {
    return _cliente.eliminar('${AppConstants.endpointSalones}/$id');
  }
}
