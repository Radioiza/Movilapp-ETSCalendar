// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificacion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordatorioExamenHash() =>
    r'63e7e944f99f75f00b26697415c4c22f9530a63e';

/// `Notifier` que coordina el **recordatorio local** de la fecha de examen.
///
/// Traduce la entidad `Examen` (dominio del feature `exams`) al lenguaje
/// genérico que entiende [NotificacionService] (id/título/cuerpo/fecha),
/// evitando acoplar el servicio de notificaciones a otros features.
///
/// Copied from [RecordatorioExamen].
@ProviderFor(RecordatorioExamen)
final recordatorioExamenProvider =
    AutoDisposeAsyncNotifierProvider<RecordatorioExamen, void>.internal(
  RecordatorioExamen.new,
  name: r'recordatorioExamenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordatorioExamenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecordatorioExamen = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
