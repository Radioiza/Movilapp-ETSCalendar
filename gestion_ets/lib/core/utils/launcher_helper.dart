import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../error/failures.dart';

/// Envoltura sobre `url_launcher` para la **interoperabilidad** pedida por
/// el proyecto: contactar a soporte por correo desde la propia app.
abstract final class LauncherHelper {
  static Future<void> enviarCorreoSoporte({String? asunto}) async {
    // Se construye el mailto a mano: `Uri.queryParameters` codifica los espacios
    // como '+' (formato de formulario) y muchos clientes de correo no lo
    // decodifican, mostrando el asunto con signos '+'. Con `encodeComponent` los
    // espacios quedan como %20, que el correo sí interpreta como espacio.
    final String consulta = (asunto == null || asunto.isEmpty)
        ? ''
        : '?subject=${Uri.encodeComponent(asunto)}';
    final Uri uri = Uri.parse('mailto:${AppConstants.correoSoporte}$consulta');
    await _abrir(uri, 'No fue posible abrir tu app de correo');
  }

  static Future<void> _abrir(Uri uri, String mensajeError) async {
    final bool exito = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!exito) {
      throw ServerFailure(mensajeError);
    }
  }
}
