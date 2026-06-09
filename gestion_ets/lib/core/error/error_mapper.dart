import 'exceptions.dart';
import 'failures.dart';

/// Traduce las [Exception]s lanzadas por los datasources (capa de datos) a
/// [Failure]s de dominio con un mensaje listo para el usuario.
///
/// Los repositorios concretos envuelven sus llamadas a datasources con
/// `try { ... } on Exception catch (e) { throw mapearAFailure(e); }`,
/// manteniendo a la capa de presentación ajena a los detalles de
/// infraestructura (HTTP, sqflite, shared_preferences, etc.).
Failure mapearAFailure(Object error) {
  return switch (error) {
    Failure f => f,
    NotFoundException e => NotFoundFailure(e.message),
    InternalServerErrorException e => InternalServerFailure(e.message),
    TimeoutException e => TimeoutFailure(e.message),
    NoConnectionException e => SinConexionFailure(e.message),
    CacheException e => CacheFailure(e.message),
    CredencialesInvalidasException e => CredencialesFailure(e.message),
    ServerException e => ServerFailure(e.message),
    _ => const ServerFailure(),
  };
}
