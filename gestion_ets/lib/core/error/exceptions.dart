/// Excepciones lanzadas por la capa de datos (datasources). La capa de
/// dominio/presentación nunca las ve directamente: los repositorios las
/// capturan y las traducen a [Failure] (ver `failures.dart`).
library;

/// Error de comunicación con el servidor (sin distinguir código HTTP).
class ServerException implements Exception {
  const ServerException([this.message = 'Ocurrió un error en el servidor']);

  final String message;
}

/// El servidor respondió 404 — recurso no encontrado.
class NotFoundException implements Exception {
  const NotFoundException([this.message = 'El recurso solicitado no existe']);

  final String message;
}

/// El servidor respondió 500 — error interno.
class InternalServerErrorException implements Exception {
  const InternalServerErrorException(
      [this.message = 'El servidor presentó un error interno']);

  final String message;
}

/// Se agotó el tiempo de espera de la conexión o de la respuesta.
class TimeoutException implements Exception {
  const TimeoutException(
      [this.message = 'La solicitud tardó demasiado en responder']);

  final String message;
}

/// No hay conexión a internet disponible.
class NoConnectionException implements Exception {
  const NoConnectionException(
      [this.message = 'No hay conexión a internet disponible']);

  final String message;
}

/// Error al leer/escribir en la caché local (sqflite / shared_preferences).
class CacheException implements Exception {
  const CacheException([this.message = 'No fue posible acceder a la caché local']);

  final String message;
}

/// Las credenciales proporcionadas no son válidas.
class CredencialesInvalidasException implements Exception {
  const CredencialesInvalidasException(
      [this.message = 'Usuario o contraseña incorrectos']);

  final String message;
}
