// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$estadisticasDashboardHash() =>
    r'7098d19fc2ad7b7b2c717b7fefbd30d95b94cc3d';

/// Estadísticas del **Panel de Control** administrativo.
///
/// Se deriva (`ref.watch`) de la lista de exámenes administrada por
/// [ExamenesAdmin]: cualquier alta/baja/cambio se refleja aquí de forma
/// reactiva, sin volver a consultar al backend.
///
/// Copied from [estadisticasDashboard].
@ProviderFor(estadisticasDashboard)
final estadisticasDashboardProvider =
    AutoDisposeFutureProvider<EstadisticasDashboard>.internal(
  estadisticasDashboard,
  name: r'estadisticasDashboardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$estadisticasDashboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EstadisticasDashboardRef
    = AutoDisposeFutureProviderRef<EstadisticasDashboard>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
