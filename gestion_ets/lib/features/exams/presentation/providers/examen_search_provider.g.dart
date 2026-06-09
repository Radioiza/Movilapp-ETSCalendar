// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'examen_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examenPorIdHash() => r'9bc66bfb03c275a0c5a1157cf7d13069388733b6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Detalle de un examen específico — usado por la pantalla de detalle /
/// exportación individual y por el flujo de recordatorios.
///
/// Copied from [examenPorId].
@ProviderFor(examenPorId)
const examenPorIdProvider = ExamenPorIdFamily();

/// Detalle de un examen específico — usado por la pantalla de detalle /
/// exportación individual y por el flujo de recordatorios.
///
/// Copied from [examenPorId].
class ExamenPorIdFamily extends Family<AsyncValue<Examen>> {
  /// Detalle de un examen específico — usado por la pantalla de detalle /
  /// exportación individual y por el flujo de recordatorios.
  ///
  /// Copied from [examenPorId].
  const ExamenPorIdFamily();

  /// Detalle de un examen específico — usado por la pantalla de detalle /
  /// exportación individual y por el flujo de recordatorios.
  ///
  /// Copied from [examenPorId].
  ExamenPorIdProvider call(
    String id,
  ) {
    return ExamenPorIdProvider(
      id,
    );
  }

  @override
  ExamenPorIdProvider getProviderOverride(
    covariant ExamenPorIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'examenPorIdProvider';
}

/// Detalle de un examen específico — usado por la pantalla de detalle /
/// exportación individual y por el flujo de recordatorios.
///
/// Copied from [examenPorId].
class ExamenPorIdProvider extends AutoDisposeFutureProvider<Examen> {
  /// Detalle de un examen específico — usado por la pantalla de detalle /
  /// exportación individual y por el flujo de recordatorios.
  ///
  /// Copied from [examenPorId].
  ExamenPorIdProvider(
    String id,
  ) : this._internal(
          (ref) => examenPorId(
            ref as ExamenPorIdRef,
            id,
          ),
          from: examenPorIdProvider,
          name: r'examenPorIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$examenPorIdHash,
          dependencies: ExamenPorIdFamily._dependencies,
          allTransitiveDependencies:
              ExamenPorIdFamily._allTransitiveDependencies,
          id: id,
        );

  ExamenPorIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Examen> Function(ExamenPorIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExamenPorIdProvider._internal(
        (ref) => create(ref as ExamenPorIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Examen> createElement() {
    return _ExamenPorIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamenPorIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExamenPorIdRef on AutoDisposeFutureProviderRef<Examen> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ExamenPorIdProviderElement
    extends AutoDisposeFutureProviderElement<Examen> with ExamenPorIdRef {
  _ExamenPorIdProviderElement(super.provider);

  @override
  String get id => (origin as ExamenPorIdProvider).id;
}

String _$filtrosBusquedaHash() => r'7307ef6450af1fe48719efefffb66c1a0fd94c35';

/// Estado de los filtros del **Buscador Inteligente** (Carrera, Semestre y
/// Unidad de Aprendizaje). Mantenerlo en su propio `Notifier` permite que la
/// pantalla de búsqueda y la tabla de resultados reaccionen de forma
/// independiente y reactiva, sin usar `setState`.
///
/// Copied from [FiltrosBusqueda].
@ProviderFor(FiltrosBusqueda)
final filtrosBusquedaProvider =
    AutoDisposeNotifierProvider<FiltrosBusqueda, FiltrosExamen>.internal(
  FiltrosBusqueda.new,
  name: r'filtrosBusquedaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filtrosBusquedaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FiltrosBusqueda = AutoDisposeNotifier<FiltrosExamen>;
String _$resultadosBusquedaHash() =>
    r'0f21e5e0a29bfaa0c9cfa03389b4bba4ec264d6d';

/// Resultados de la búsqueda: se recalculan automáticamente cada vez que
/// cambian los filtros (`ref.watch`), combinando backend remoto y caché
/// local de forma transparente gracias al repositorio offline-first.
///
/// Copied from [ResultadosBusqueda].
@ProviderFor(ResultadosBusqueda)
final resultadosBusquedaProvider =
    AutoDisposeAsyncNotifierProvider<ResultadosBusqueda, List<Examen>>.internal(
  ResultadosBusqueda.new,
  name: r'resultadosBusquedaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resultadosBusquedaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ResultadosBusqueda = AutoDisposeAsyncNotifier<List<Examen>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
