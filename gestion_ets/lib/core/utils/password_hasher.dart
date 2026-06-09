import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Utilidad para encriptar contraseñas mediante **SHA-256 con sal aleatoria**,
/// requisito de "Login seguro con contraseñas encriptadas" del proyecto.
///
/// La contraseña nunca se almacena ni se transmite en texto plano: se guarda
/// `sal:hash`, y al iniciar sesión se recalcula el hash con la sal guardada
/// y se compara contra el valor almacenado.
abstract final class PasswordHasher {
  static const int _longitudSal = 16;

  /// Genera `sal:hash` a partir de una contraseña en texto plano.
  static String encriptar(String contrasenaPlana) {
    final String sal = _generarSal();
    final String hash = _hashConSal(contrasenaPlana, sal);
    return '$sal:$hash';
  }

  /// Compara una contraseña en texto plano contra el valor `sal:hash` guardado.
  static bool verificar(String contrasenaPlana, String valorAlmacenado) {
    final List<String> partes = valorAlmacenado.split(':');
    if (partes.length != 2) {
      return false;
    }
    final String sal = partes.first;
    final String hashGuardado = partes.last;
    final String hashCalculado = _hashConSal(contrasenaPlana, sal);
    return _compararEnTiempoConstante(hashCalculado, hashGuardado);
  }

  static String _hashConSal(String contrasenaPlana, String sal) {
    final List<int> bytes = utf8.encode('$sal::$contrasenaPlana');
    return sha256.convert(bytes).toString();
  }

  static String _generarSal() {
    final Random aleatorio = Random.secure();
    final List<int> valores =
        List<int>.generate(_longitudSal, (_) => aleatorio.nextInt(256));
    return base64UrlEncode(valores);
  }

  static bool _compararEnTiempoConstante(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    int diferencia = 0;
    for (int i = 0; i < a.length; i++) {
      diferencia |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diferencia == 0;
  }
}
