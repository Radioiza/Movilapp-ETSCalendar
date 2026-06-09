import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Envoltura sobre [http.Client] que centraliza el consumo de la API REST y
/// traduce las respuestas/errores de red a las [Exception]s del dominio
/// (`ServerException`, `NotFoundException`, `InternalServerErrorException`,
/// `TimeoutException`, `NoConnectionException`).
///
/// Los datasources remotos NO deben usar `http` directamente: pasan siempre
/// por aquí para que el manejo de errores (timeouts, 404, 500) sea uniforme
/// y profesional en toda la app.
class ApiClient {
  ApiClient({http.Client? cliente, String? baseUrl})
      : _cliente = cliente ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  final http.Client _cliente;
  final String _baseUrl;

  Future<dynamic> obtener(String endpoint, {Map<String, String>? parametros}) {
    final Uri uri = Uri.parse('$_baseUrl$endpoint')
        .replace(queryParameters: parametros);
    return _ejecutar(() => _cliente.get(uri, headers: _encabezados()));
  }

  Future<dynamic> publicar(String endpoint, {Object? cuerpo}) {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    return _ejecutar(
      () => _cliente.post(uri, headers: _encabezados(), body: jsonEncode(cuerpo)),
    );
  }

  Future<dynamic> actualizar(String endpoint, {Object? cuerpo}) {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    return _ejecutar(
      () => _cliente.put(uri, headers: _encabezados(), body: jsonEncode(cuerpo)),
    );
  }

  Future<dynamic> eliminar(String endpoint) {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    return _ejecutar(() => _cliente.delete(uri, headers: _encabezados()));
  }

  Map<String, String> _encabezados() => const <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  /// Ejecuta la petición aplicando timeout y traduciendo códigos de estado /
  /// errores de bajo nivel a excepciones del dominio.
  Future<dynamic> _ejecutar(Future<http.Response> Function() peticion) async {
    try {
      final http.Response respuesta = await peticion().timeout(
        AppConstants.receiveTimeout,
        onTimeout: () => throw const TimeoutException(),
      );
      return _interpretar(respuesta);
    } on TimeoutException {
      rethrow;
    } on SocketException {
      throw const NoConnectionException();
    } on HandshakeException {
      throw const ServerException('No fue posible establecer una conexión segura');
    } on FormatException {
      throw const ServerException('El servidor devolvió una respuesta no válida');
    } on Exception catch (_) {
      throw const ServerException();
    }
  }

  dynamic _interpretar(http.Response respuesta) {
    final int codigo = respuesta.statusCode;
    final String cuerpo = respuesta.body;

    switch (codigo) {
      case >= 200 && < 300:
        if (cuerpo.isEmpty) {
          return null;
        }
        return jsonDecode(cuerpo);
      case 404:
        throw const NotFoundException();
      case 408:
        throw const TimeoutException();
      case >= 500:
        throw const InternalServerErrorException();
      case 401:
      case 403:
        throw const CredencialesInvalidasException(
          'No tienes permisos para realizar esta acción',
        );
      default:
        throw ServerException(_mensajeDeError(cuerpo, codigo));
    }
  }

  String _mensajeDeError(String cuerpo, int codigo) {
    try {
      final dynamic decodificado = jsonDecode(cuerpo);
      if (decodificado is Map<String, dynamic> && decodificado['mensaje'] is String) {
        return decodificado['mensaje'] as String;
      }
    } on FormatException {
      // El cuerpo no es JSON; se conserva el mensaje genérico.
    }
    return 'El servidor respondió con el código $codigo';
  }

  void cerrar() => _cliente.close();
}
