import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_provider.g.dart';

/// Estado de autenticación del Módulo Administrativo, expresado como
/// `AsyncValue<Usuario?>`:
/// - `loading` → validando credenciales / recuperando sesión.
/// - `data(null)` → no hay sesión activa (se muestra el login).
/// - `data(Usuario)` → sesión activa (se muestra el panel administrativo).
/// - `error` → la última operación falló (credenciales inválidas, red, etc.).
///
/// Se construye con `@riverpod` (codegen) según lo definido para el manejo
/// de estado del proyecto.
@riverpod
class SesionAuth extends _$SesionAuth {
  AuthRepository get _repositorio => sl<AuthRepository>();
  LoginUseCase get _login => sl<LoginUseCase>();

  @override
  FutureOr<Usuario?> build() {
    return _repositorio.obtenerSesionActual();
  }

  Future<void> iniciarSesion({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    state = const AsyncValue<Usuario?>.loading();
    state = await AsyncValue.guard(
      () => _login.ejecutar(nombreUsuario: nombreUsuario, contrasena: contrasena),
    );
  }

  Future<void> cerrarSesion() async {
    state = const AsyncValue<Usuario?>.loading();
    state = await AsyncValue.guard(() async {
      await _repositorio.cerrarSesion();
      return null;
    });
  }
}

/// Atajo para conocer si hay una sesión administrativa activa, usado por el
/// enrutador para decidir entre mostrar el login o el panel.
@riverpod
bool haySesionActiva(Ref ref) {
  final AsyncValue<Usuario?> sesion = ref.watch(sesionAuthProvider);
  return sesion.valueOrNull != null;
}
