import '../../exams/domain/entities/examen.dart';

/// Conteo de exámenes agrupados por una etiqueta (carrera, turno, etc.),
/// usado para alimentar las gráficas de barras del panel de control.
class ConteoPorEtiqueta {
  const ConteoPorEtiqueta({required this.etiqueta, required this.total});

  final String etiqueta;
  final int total;
}

/// Estadísticas rápidas del **Panel de Control (Dashboard)** administrativo:
/// totales, próximos exámenes y desgloses por carrera y turno.
///
/// Se calcula a partir de la oferta de exámenes ya cargada — es lógica de
/// negocio pura (sin acceso a datos), por lo que vive en el dominio.
class EstadisticasDashboard {
  const EstadisticasDashboard({
    required this.totalExamenes,
    required this.examenesPorCarrera,
    required this.examenesPorTurno,
    required this.proximosExamenes,
  });

  factory EstadisticasDashboard.calcular(List<Examen> examenes) {
    final Map<String, int> porCarrera = <String, int>{};
    final Map<String, int> porTurno = <String, int>{};

    for (final Examen examen in examenes) {
      porCarrera.update(examen.carreraNombre, (int v) => v + 1, ifAbsent: () => 1);
      porTurno.update(examen.turno.etiqueta, (int v) => v + 1, ifAbsent: () => 1);
    }

    final DateTime ahora = DateTime.now();
    final List<Examen> proximos = examenes
        .where((Examen e) => e.fecha.isAfter(ahora))
        .toList()
      ..sort((Examen a, Examen b) => a.fecha.compareTo(b.fecha));

    return EstadisticasDashboard(
      totalExamenes: examenes.length,
      examenesPorCarrera: porCarrera.entries
          .map((MapEntry<String, int> e) => ConteoPorEtiqueta(etiqueta: e.key, total: e.value))
          .toList()
        ..sort((ConteoPorEtiqueta a, ConteoPorEtiqueta b) => b.total.compareTo(a.total)),
      examenesPorTurno: porTurno.entries
          .map((MapEntry<String, int> e) => ConteoPorEtiqueta(etiqueta: e.key, total: e.value))
          .toList(),
      proximosExamenes: proximos.take(5).toList(),
    );
  }

  final int totalExamenes;
  final List<ConteoPorEtiqueta> examenesPorCarrera;
  final List<ConteoPorEtiqueta> examenesPorTurno;
  final List<Examen> proximosExamenes;
}
