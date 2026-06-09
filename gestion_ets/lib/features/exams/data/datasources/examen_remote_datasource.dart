import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/examen_model.dart';

/// Fuente de datos remota: consume los endpoints del backend REST para la
/// oferta de exámenes. Cualquier error de red ya llega traducido a
/// excepciones de dominio gracias a [ApiClient].
class ExamenRemoteDataSource {
  const ExamenRemoteDataSource(this._cliente);

  final ApiClient _cliente;

  Future<List<ExamenModel>> obtenerExamenes() async {
    final dynamic respuesta = await _cliente.obtener(AppConstants.endpointExamenes);
    final List<dynamic> lista = respuesta as List<dynamic>;
    return lista
        .map((dynamic json) => ExamenModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ExamenModel> crear(ExamenModel examen) async {
    final dynamic respuesta = await _cliente.publicar(
      AppConstants.endpointExamenes,
      cuerpo: examen.toJson(),
    );
    return ExamenModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<ExamenModel> actualizar(ExamenModel examen) async {
    final dynamic respuesta = await _cliente.actualizar(
      '${AppConstants.endpointExamenes}/${examen.id}',
      cuerpo: examen.toJson(),
    );
    return ExamenModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<void> eliminar(String id) {
    return _cliente.eliminar('${AppConstants.endpointExamenes}/$id');
  }
}
