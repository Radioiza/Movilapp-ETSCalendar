import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/utils/password_hasher.dart';

/// Módulo Administrativo · Autenticación: "Login seguro con contraseñas
/// encriptadas". Se verifica que la contraseña nunca se guarde en claro y que
/// la verificación funcione (correcta/incorrecta).
void main() {
  group('PasswordHasher', () {
    test('encripta en formato sal:hash y nunca expone la contraseña', () {
      final String almacenado = PasswordHasher.encriptar('admin123');

      expect(almacenado.split(':').length, 2,
          reason: 'Debe guardarse como sal:hash');
      expect(almacenado.contains('admin123'), isFalse,
          reason: 'La contraseña en claro no debe aparecer');
    });

    test('verifica correctamente la contraseña correcta', () {
      final String almacenado = PasswordHasher.encriptar('S3gura!');
      expect(PasswordHasher.verificar('S3gura!', almacenado), isTrue);
    });

    test('rechaza una contraseña incorrecta', () {
      final String almacenado = PasswordHasher.encriptar('S3gura!');
      expect(PasswordHasher.verificar('incorrecta', almacenado), isFalse);
    });

    test('usa sal aleatoria: la misma contraseña produce hashes distintos', () {
      final String a = PasswordHasher.encriptar('misma');
      final String b = PasswordHasher.encriptar('misma');
      expect(a, isNot(equals(b)),
          reason: 'Sin sal aleatoria el sistema sería vulnerable a rainbow tables');
      // pero ambas verifican
      expect(PasswordHasher.verificar('misma', a), isTrue);
      expect(PasswordHasher.verificar('misma', b), isTrue);
    });

    test('un valor almacenado mal formado no truena y devuelve false', () {
      expect(PasswordHasher.verificar('x', 'sin-dos-puntos'), isFalse);
      expect(PasswordHasher.verificar('x', ''), isFalse);
    });
  });
}
