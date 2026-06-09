import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/error/failures.dart';
import 'package:gestion_ets/features/auth/domain/entities/usuario.dart';
import 'package:gestion_ets/features/auth/domain/repositories/auth_repository.dart';
import 'package:gestion_ets/features/auth/domain/usecases/login_usecase.dart';

/// Repositorio falso que registra la última llamada para verificar la
/// delegación y el saneamiento de entrada del [LoginUseCase].
class _AuthRepoFake implements AuthRepository {
  String? usuarioRecibido;
  String? contrasenaRecibida;

  @override
  Future<Usuario> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    usuarioRecibido = nombreUsuario;
    contrasenaRecibida = contrasena;
    return const Usuario(
      id: '1',
      nombreUsuario: 'admin',
      nombreCompleto: 'Administrador ESCOM',
      rol: RolUsuario.administrador,
    );
  }

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<Usuario?> obtenerSesionActual() async => null;
}

void main() {
  group('LoginUseCase (validación de entrada)', () {
    late _AuthRepoFake repo;
    late LoginUseCase usecase;

    setUp(() {
      repo = _AuthRepoFake();
      usecase = LoginUseCase(repo);
    });

    test('rechaza usuario vacío', () {
      expect(
        () => usecase.ejecutar(nombreUsuario: '   ', contrasena: 'admin123'),
        throwsA(isA<ValidacionFailure>()),
      );
    });

    test('rechaza contraseña vacía', () {
      expect(
        () => usecase.ejecutar(nombreUsuario: 'admin', contrasena: ''),
        throwsA(isA<ValidacionFailure>()),
      );
    });

    test('rechaza contraseña de menos de 6 caracteres', () {
      expect(
        () => usecase.ejecutar(nombreUsuario: 'admin', contrasena: '123'),
        throwsA(isA<ValidacionFailure>()),
      );
    });

    test('credenciales válidas: recorta el usuario y delega al repositorio',
        () async {
      final Usuario usuario = await usecase.ejecutar(
        nombreUsuario: '  admin  ',
        contrasena: 'admin123',
      );

      expect(usuario.rol, RolUsuario.administrador);
      expect(repo.usuarioRecibido, 'admin',
          reason: 'El nombre de usuario debe llegar recortado al repositorio');
      expect(repo.contrasenaRecibida, 'admin123');
    });
  });
}
