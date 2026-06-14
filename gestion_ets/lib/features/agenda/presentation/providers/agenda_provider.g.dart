// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examenesEnCalendarioHash() =>
    r'1f01b1f037b2e4c486c77fe6707f491b221d0eb7';

/// **ETS que el usuario agregó a su calendario.**
///
/// Internamente reutiliza el conjunto de exámenes "guardados" (persistido con
/// `shared_preferences`) como la colección de "mi calendario", y resuelve sus
/// datos completos contra la oferta oficial. Se recalcula automáticamente
/// cuando el usuario agrega o quita un ETS.
///
/// Copied from [examenesEnCalendario].
@ProviderFor(examenesEnCalendario)
final examenesEnCalendarioProvider =
    AutoDisposeFutureProvider<List<Examen>>.internal(
  examenesEnCalendario,
  name: r'examenesEnCalendarioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$examenesEnCalendarioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExamenesEnCalendarioRef = AutoDisposeFutureProviderRef<List<Examen>>;
String _$rangoEtsHash() => r'c63f4a6c8c87e5d8599d3e705f5138082ae07e36';

/// Rango de meses con ETS **oficialmente programados** por el IPN. Se usa para
/// que el calendario no permita navegar fuera del periodo de exámenes.
/// Devuelve `null` cuando no hay oferta cargada.
///
/// Copied from [rangoEts].
@ProviderFor(rangoEts)
final rangoEtsProvider = AutoDisposeFutureProvider<RangoEts?>.internal(
  rangoEts,
  name: r'rangoEtsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$rangoEtsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RangoEtsRef = AutoDisposeFutureProviderRef<RangoEts?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
