/// Representación de errores en las capas de dominio y presentación.
///
/// Los datasources lanzan [Exception]s (ver `exceptions.dart`); los
/// repositorios las capturan y las traducen a un [Failure] con un mensaje
/// listo para mostrarse al usuario (Snackbar / diálogo), evitando que
/// detalles de infraestructura se filtren hacia la UI.
///
/// [Failure] implementa [Exception] para poder lanzarse directamente desde
/// los repositorios: los `AsyncNotifier` de Riverpod capturan la excepción de
/// forma natural en `AsyncValue.error`, y la presentación solo necesita
/// comprobar `error is Failure` para mostrar `failure.message`.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

/// Error de servidor (respuesta inesperada del backend).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor']);
}

/// El recurso solicitado no existe (HTTP 404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No se encontró la información solicitada']);
}

/// Error interno del servidor (HTTP 500).
class InternalServerFailure extends Failure {
  const InternalServerFailure(
      [super.message = 'El servidor presentó un problema, intenta más tarde']);
}

/// Tiempo de espera agotado al contactar el backend.
class TimeoutFailure extends Failure {
  const TimeoutFailure(
      [super.message = 'La solicitud tardó demasiado, revisa tu conexión']);
}

/// Sin conexión a internet — la app puede seguir operando con datos en caché.
class SinConexionFailure extends Failure {
  const SinConexionFailure(
      [super.message = 'Sin conexión a internet. Mostrando datos guardados']);
}

/// Error al leer/escribir en la base de datos local o preferencias.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No fue posible acceder a la información local']);
}

/// Credenciales incorrectas al iniciar sesión.
class CredencialesFailure extends Failure {
  const CredencialesFailure([super.message = 'Usuario o contraseña incorrectos']);
}

/// Error de validación de datos de entrada (formularios).
class ValidacionFailure extends Failure {
  const ValidacionFailure(super.message);
}
