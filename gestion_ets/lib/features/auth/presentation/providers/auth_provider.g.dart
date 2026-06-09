// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$haySesionActivaHash() => r'd51200f91c52019ba1d4c725da74c100d9870a1b';

/// Atajo para conocer si hay una sesión administrativa activa, usado por el
/// enrutador para decidir entre mostrar el login o el panel.
///
/// Copied from [haySesionActiva].
@ProviderFor(haySesionActiva)
final haySesionActivaProvider = AutoDisposeProvider<bool>.internal(
  haySesionActiva,
  name: r'haySesionActivaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$haySesionActivaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HaySesionActivaRef = AutoDisposeProviderRef<bool>;
String _$sesionAuthHash() => r'528d80a2b9fdd2cea6533e8fd698c6941baac234';

/// Estado de autenticación del Módulo Administrativo, expresado como
/// `AsyncValue<Usuario?>`:
/// - `loading` → validando credenciales / recuperando sesión.
/// - `data(null)` → no hay sesión activa (se muestra el login).
/// - `data(Usuario)` → sesión activa (se muestra el panel administrativo).
/// - `error` → la última operación falló (credenciales inválidas, red, etc.).
///
/// Se construye con `@riverpod` (codegen) según lo definido para el manejo
/// de estado del proyecto.
///
/// Copied from [SesionAuth].
@ProviderFor(SesionAuth)
final sesionAuthProvider =
    AutoDisposeAsyncNotifierProvider<SesionAuth, Usuario?>.internal(
  SesionAuth.new,
  name: r'sesionAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sesionAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SesionAuth = AutoDisposeAsyncNotifier<Usuario?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
