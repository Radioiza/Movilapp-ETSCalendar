import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/features/dashboard/domain/estadisticas_dashboard.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';

import '../helpers/datos_prueba.dart';

/// Módulo Administrativo · Panel de Control (Dashboard): estadísticas rápidas,
/// p. ej. cuántos exámenes hay por carrera.
void main() {
  group('EstadisticasDashboard.calcular', () {
    test('cuenta el total y agrupa por carrera y por turno', () {
      final List<Examen> examenes = <Examen>[
        examenDePrueba(id: '1', carreraNombre: 'ISC', turno: Turno.matutino),
        examenDePrueba(id: '2', carreraNombre: 'ISC', turno: Turno.vespertino),
        examenDePrueba(id: '3', carreraNombre: 'LCD', turno: Turno.matutino),
      ];

      final EstadisticasDashboard stats =
          EstadisticasDashboard.calcular(examenes);

      expect(stats.totalExamenes, 3);

      final Map<String, int> porCarrera = <String, int>{
        for (final ConteoPorEtiqueta c in stats.examenesPorCarrera)
          c.etiqueta: c.total,
      };
      expect(porCarrera['ISC'], 2);
      expect(porCarrera['LCD'], 1);

      final Map<String, int> porTurno = <String, int>{
        for (final ConteoPorEtiqueta c in stats.examenesPorTurno)
          c.etiqueta: c.total,
      };
      expect(porTurno['Matutino'], 2);
      expect(porTurno['Vespertino'], 1);
    });

    test('ordena las carreras de mayor a menor cantidad', () {
      final List<Examen> examenes = <Examen>[
        examenDePrueba(id: '1', carreraNombre: 'LCD'),
        examenDePrueba(id: '2', carreraNombre: 'ISC'),
        examenDePrueba(id: '3', carreraNombre: 'ISC'),
        examenDePrueba(id: '4', carreraNombre: 'ISC'),
      ];

      final EstadisticasDashboard stats =
          EstadisticasDashboard.calcular(examenes);

      expect(stats.examenesPorCarrera.first.etiqueta, 'ISC');
      expect(stats.examenesPorCarrera.first.total, 3);
    });

    test('próximos exámenes: solo futuros, ordenados y máximo 5', () {
      final DateTime ahora = DateTime.now();
      final List<Examen> examenes = <Examen>[
        examenDePrueba(id: 'pasado', fecha: ahora.subtract(const Duration(days: 2))),
        for (int i = 0; i < 7; i++)
          examenDePrueba(id: 'f$i', fecha: ahora.add(Duration(days: i + 1))),
      ];

      final EstadisticasDashboard stats =
          EstadisticasDashboard.calcular(examenes);

      expect(stats.proximosExamenes.length, 5,
          reason: 'Se limita a los 5 más próximos');
      expect(
        stats.proximosExamenes.any((Examen e) => e.id == 'pasado'),
        isFalse,
        reason: 'No debe incluir exámenes ya pasados',
      );
      // Verifica orden cronológico ascendente.
      for (int i = 0; i < stats.proximosExamenes.length - 1; i++) {
        expect(
          stats.proximosExamenes[i].fecha
              .isBefore(stats.proximosExamenes[i + 1].fecha),
          isTrue,
        );
      }
    });

    test('lista vacía no truena y da estadísticas en cero', () {
      final EstadisticasDashboard stats =
          EstadisticasDashboard.calcular(<Examen>[]);
      expect(stats.totalExamenes, 0);
      expect(stats.examenesPorCarrera, isEmpty);
      expect(stats.proximosExamenes, isEmpty);
    });
  });
}
