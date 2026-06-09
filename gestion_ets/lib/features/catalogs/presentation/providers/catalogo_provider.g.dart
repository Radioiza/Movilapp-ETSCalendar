// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$carrerasCatalogoHash() => r'4ec2d8b1078936e422ab3f69e10ae124d1e85204';

/// Catálogo de Carreras — consultado por el buscador público (filtros) y
/// administrado (alta/edición/baja) desde el panel administrativo.
///
/// Copied from [CarrerasCatalogo].
@ProviderFor(CarrerasCatalogo)
final carrerasCatalogoProvider =
    AutoDisposeAsyncNotifierProvider<CarrerasCatalogo, List<Carrera>>.internal(
  CarrerasCatalogo.new,
  name: r'carrerasCatalogoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$carrerasCatalogoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CarrerasCatalogo = AutoDisposeAsyncNotifier<List<Carrera>>;
String _$salonesCatalogoHash() => r'13fd5c222c060581977d9536a9c91d594c745801';

/// Catálogo de Edificios/Salones — análogo al de Carreras.
///
/// Copied from [SalonesCatalogo].
@ProviderFor(SalonesCatalogo)
final salonesCatalogoProvider =
    AutoDisposeAsyncNotifierProvider<SalonesCatalogo, List<Salon>>.internal(
  SalonesCatalogo.new,
  name: r'salonesCatalogoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$salonesCatalogoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SalonesCatalogo = AutoDisposeAsyncNotifier<List<Salon>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
