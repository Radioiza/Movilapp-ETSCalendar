// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'examen_admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examenesAdminHash() => r'20ee5dd690675bb78d738706326544c9b0ceb309';

/// `Notifier` que respalda el **CRUD completo de la oferta de exámenes**
/// del Módulo Administrativo (Altas, Bajas, Cambios y Consultas).
///
/// Cada operación de escritura reconstruye la lista a partir del repositorio
/// para que la tabla administrativa, el buscador público y el dashboard
/// permanezcan consistentes entre sí.
///
/// Copied from [ExamenesAdmin].
@ProviderFor(ExamenesAdmin)
final examenesAdminProvider =
    AutoDisposeAsyncNotifierProvider<ExamenesAdmin, List<Examen>>.internal(
  ExamenesAdmin.new,
  name: r'examenesAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$examenesAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExamenesAdmin = AutoDisposeAsyncNotifier<List<Examen>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
