import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';
import 'package:gestion_ets/features/export/domain/ics_export_service.dart';

import '../helpers/datos_prueba.dart';

/// Módulo Público · Exportación: archivo .ics (iCalendar / RFC 5545) — puntos
/// extra. Se valida el contenido generado (estructura, eventos y escapado).
void main() {
  group('IcsExportService.construirIcs', () {
    test('genera un VCALENDAR con un VEVENT por examen y CRLF', () {
      final List<Examen> examenes = <Examen>[
        examenDePrueba(id: 'e1', unidadAprendizaje: 'Cálculo'),
        examenDePrueba(id: 'e2', unidadAprendizaje: 'Álgebra'),
      ];

      final String ics = IcsExportService.construirIcs(examenes);

      expect(ics, startsWith('BEGIN:VCALENDAR'));
      expect(ics.trimRight(), endsWith('END:VCALENDAR'));
      expect('BEGIN:VEVENT'.allMatches(ics).length, 2);
      expect('END:VEVENT'.allMatches(ics).length, 2);
      expect(ics.contains('VERSION:2.0'), isTrue);
      expect(ics.contains('\r\n'), isTrue,
          reason: 'iCalendar exige terminaciones CRLF');
    });

    test('incluye SUMMARY, LOCATION, UID y fechas en UTC (Z) por examen', () {
      final String ics = IcsExportService.construirIcs(<Examen>[
        examenDePrueba(
          id: 'abc',
          unidadAprendizaje: 'Cálculo',
          salonNombre: 'Edificio 1 · 101',
          fecha: DateTime.utc(2026, 7, 6, 9),
        ),
      ]);

      expect(ics.contains('UID:abc@gestionets.escom.ipn.mx'), isTrue);
      expect(ics.contains('SUMMARY:ETS · Cálculo'), isTrue);
      expect(ics.contains('LOCATION:Edificio 1 · 101'), isTrue);
      expect(ics.contains('DTSTART:20260706T090000Z'), isTrue);
      // Duración de 2 horas -> fin 11:00.
      expect(ics.contains('DTEND:20260706T110000Z'), isTrue);
    });

    test('escapa comas, puntos y coma y saltos de línea en TEXT', () {
      final String ics = IcsExportService.construirIcs(<Examen>[
        examenDePrueba(
          unidadAprendizaje: 'Redes, Seguridad; Avanzada',
          profesorEvaluador: 'Apellido, Nombre',
        ),
      ]);

      expect(ics.contains(r'Redes\, Seguridad\; Avanzada'), isTrue);
      expect(ics.contains(r'Apellido\, Nombre'), isTrue);
    });

    test('lista vacía produce un VCALENDAR válido sin eventos', () {
      final String ics = IcsExportService.construirIcs(<Examen>[]);
      expect(ics.contains('BEGIN:VEVENT'), isFalse);
      expect(ics.contains('BEGIN:VCALENDAR'), isTrue);
      expect(ics.contains('END:VCALENDAR'), isTrue);
    });
  });
}
