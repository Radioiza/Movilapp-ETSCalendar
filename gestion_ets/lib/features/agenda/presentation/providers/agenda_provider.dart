import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../exams/domain/entities/examen.dart';
import '../../../exams/domain/repositories/examen_repository.dart';
import '../../../favorites/presentation/providers/favoritos_provider.dart';

part 'agenda_provider.g.dart';

/// **ETS que el usuario agregó a su calendario.**
///
/// Internamente reutiliza el conjunto de exámenes "guardados" (persistido con
/// `shared_preferences`) como la colección de "mi calendario", y resuelve sus
/// datos completos contra la oferta oficial. Se recalcula automáticamente
/// cuando el usuario agrega o quita un ETS.
@riverpod
Future<List<Examen>> examenesEnCalendario(Ref ref) async {
  final Set<String> ids = await ref.watch(favoritosExamenesProvider.future);
  if (ids.isEmpty) {
    return const <Examen>[];
  }
  final List<Examen> todos = await sl<ExamenRepository>().obtenerTodos();
  return todos.where((Examen e) => ids.contains(e.id)).toList()
    ..sort((Examen a, Examen b) => a.fecha.compareTo(b.fecha));
}

/// Rango de meses con ETS **oficialmente programados** por el IPN. Se usa para
/// que el calendario no permita navegar fuera del periodo de exámenes.
/// Devuelve `null` cuando no hay oferta cargada.
@riverpod
Future<RangoEts?> rangoEts(Ref ref) async {
  final List<Examen> todos = await sl<ExamenRepository>().obtenerTodos();
  if (todos.isEmpty) {
    return null;
  }
  DateTime minima = todos.first.fecha;
  DateTime maxima = todos.first.fecha;
  for (final Examen examen in todos) {
    if (examen.fecha.isBefore(minima)) {
      minima = examen.fecha;
    }
    if (examen.fecha.isAfter(maxima)) {
      maxima = examen.fecha;
    }
  }
  return RangoEts(
    primerMes: DateTime(minima.year, minima.month),
    ultimoMes: DateTime(maxima.year, maxima.month),
  );
}

/// Periodo (primer y último mes) en que hay ETS programados.
class RangoEts {
  const RangoEts({required this.primerMes, required this.ultimoMes});

  final DateTime primerMes;
  final DateTime ultimoMes;

  /// Acota [mes] al rango `[primerMes, ultimoMes]`.
  DateTime acotar(DateTime mes) {
    if (mes.isBefore(primerMes)) {
      return primerMes;
    }
    if (mes.isAfter(ultimoMes)) {
      return ultimoMes;
    }
    return mes;
  }

  bool contieneDia(DateTime dia) {
    final DateTime mes = DateTime(dia.year, dia.month);
    return !mes.isBefore(primerMes) && !mes.isAfter(ultimoMes);
  }
}
