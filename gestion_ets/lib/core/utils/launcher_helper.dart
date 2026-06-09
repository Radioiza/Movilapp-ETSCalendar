import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../error/failures.dart';

/// Envoltura sobre `url_launcher` para la **interoperabilidad** pedida por
/// el proyecto: abrir la ubicación de un salón en el mapa o contactar a
/// soporte (correo / teléfono) desde la propia app.
abstract final class LauncherHelper {
  /// Abre [direccionMapa] en la app de mapas del dispositivo. Si el salón no
  /// tiene una dirección registrada, construye una búsqueda por nombre.
  static Future<void> abrirUbicacionSalon({
    required String nombreCompleto,
    String? direccionMapa,
  }) async {
    final Uri uri = direccionMapa != null && direccionMapa.isNotEmpty
        ? Uri.parse(direccionMapa)
        : Uri.https('www.google.com', '/maps/search/', <String, String>{
            'api': '1',
            'query': 'ESCOM IPN $nombreCompleto',
          });
    await _abrir(uri, 'No fue posible abrir el mapa del salón');
  }

  static Future<void> enviarCorreoSoporte({String? asunto}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: AppConstants.correoSoporte,
      queryParameters: asunto == null ? null : <String, String>{'subject': asunto},
    );
    await _abrir(uri, 'No fue posible abrir tu app de correo');
  }

  static Future<void> llamarSoporte() async {
    final Uri uri = Uri(scheme: 'tel', path: AppConstants.telefonoSoporte);
    await _abrir(uri, 'No fue posible iniciar la llamada');
  }

  static Future<void> _abrir(Uri uri, String mensajeError) async {
    final bool exito = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!exito) {
      throw ServerFailure(mensajeError);
    }
  }
}
