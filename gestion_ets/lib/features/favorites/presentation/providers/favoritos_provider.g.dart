// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favoritos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritosExamenesHash() => r'310028b704ca7749218ede465b45eac08008fcfd';

/// Conjunto de identificadores de **exámenes favoritos/guardados**,
/// persistido con `shared_preferences` (caché local offline-first).
///
/// Se expone como `Set<String>` para que cualquier tarjeta de examen pueda
/// preguntar `favoritos.contains(examen.id)` sin recorrer listas.
///
/// Copied from [FavoritosExamenes].
@ProviderFor(FavoritosExamenes)
final favoritosExamenesProvider =
    AutoDisposeAsyncNotifierProvider<FavoritosExamenes, Set<String>>.internal(
  FavoritosExamenes.new,
  name: r'favoritosExamenesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoritosExamenesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FavoritosExamenes = AutoDisposeAsyncNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
