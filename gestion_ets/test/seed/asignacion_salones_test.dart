import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/core/local/seed/datos_semilla_escom.dart';
import 'package:gestion_ets/core/local/seed/sembrador_datos.dart';
import 'package:gestion_ets/features/catalogs/data/models/salon_model.dart';
import 'package:gestion_ets/features/exams/data/models/examen_model.dart';

/// Verifica la regla de asignación de salones de los ETS sembrados:
/// cada materia cae en el laboratorio/aula de su área y no hay traslapes
/// (mismo salón, mismo día y turno) en toda la oferta.
void main() {
  final List<ExamenModel> examenes = SembradorDatos.generarExamenes();

  // Mapa salonId -> área, a partir de los pools por área.
  final Map<String, AreaEts> areaPorSalon = <String, AreaEts>{};
  DatosSemillaEscom.salonesPorArea.forEach((AreaEts area, List<SalonModel> pool) {
    for (final SalonModel salon in pool) {
      areaPorSalon[salon.id] = area;
    }
  });

  test('se generan exámenes en ambos turnos', () {
    expect(examenes, isNotEmpty);
    // Cada materia se ofrece en matutino y vespertino: total par.
    expect(examenes.length.isEven, isTrue);
  });

  test('no hay traslapes: ningún salón se repite en el mismo día y hora', () {
    final Set<String> ocupacion = <String>{};
    for (final ExamenModel e in examenes) {
      // La fecha ya incluye la hora del bloque, así que la llave cubre día+hora.
      final String llave = '${e.salonId}@${e.fecha.toIso8601String()}';
      expect(ocupacion.add(llave), isTrue,
          reason: 'Traslape en ${e.salonNombre} el ${e.fecha} (${e.unidadAprendizaje})');
    }
  });

  test('todos los ETS caen en la semana oficial (lun 6 – vie 10 de julio 2026)', () {
    final DateTime inicio = DateTime(2026, 7, 6);
    final DateTime fin = DateTime(2026, 7, 10, 23, 59, 59);
    for (final ExamenModel e in examenes) {
      expect(e.fecha.isBefore(inicio), isFalse,
          reason: '${e.unidadAprendizaje} se programó antes del 6 de julio: ${e.fecha}');
      expect(e.fecha.isAfter(fin), isFalse,
          reason: '${e.unidadAprendizaje} se programó después del 10 de julio: ${e.fecha}');
      expect(e.fecha.weekday, lessThanOrEqualTo(DateTime.friday),
          reason: '${e.unidadAprendizaje} cayó en fin de semana: ${e.fecha}');
    }
  });

  test('los ETS se aplican en bloques de 2 h entre las 7:00 y las 20:00', () {
    for (final ExamenModel e in examenes) {
      expect(e.fecha.minute, 0, reason: 'Hora no alineada a bloque: ${e.fecha}');
      expect(e.fecha.hour, greaterThanOrEqualTo(7),
          reason: '${e.unidadAprendizaje} empieza antes de las 7:00: ${e.fecha}');
      // El examen dura 2 h, así que debe iniciar a más tardar a las 18:00.
      expect(e.fecha.hour, lessThanOrEqualTo(18),
          reason: '${e.unidadAprendizaje} terminaría después de las 20:00: ${e.fecha}');
    }
  });

  test('cada examen cae en el salón del área correcta de su materia', () {
    for (final ExamenModel e in examenes) {
      final AreaEts areaEsperada = DatosSemillaEscom.areaDe(e.unidadAprendizaje);
      expect(areaPorSalon[e.salonId], areaEsperada,
          reason: '${e.unidadAprendizaje} debería estar en un salón de $areaEsperada, '
              'no en ${e.salonNombre}');
    }
  });

  test('las materias especializadas usan exactamente sus laboratorios', () {
    void verificar(String materia, Set<String> salonesPermitidos) {
      final Iterable<ExamenModel> deLaMateria =
          examenes.where((ExamenModel e) => e.unidadAprendizaje == materia);
      expect(deLaMateria, isNotEmpty, reason: 'No se generó ningún ETS de $materia');
      for (final ExamenModel e in deLaMateria) {
        expect(salonesPermitidos.contains(e.salonId), isTrue,
            reason: '$materia cayó en ${e.salonNombre}');
      }
    }

    verificar('Sistemas en Chip', <String>{'lab-dsd-1', 'lab-dsd-2'});
    verificar('Arquitectura de Computadoras', <String>{'lab-dsd-1', 'lab-dsd-2'});
    verificar('Inteligencia Artificial', <String>{'lab-ia-1', 'lab-ia-2'});
    verificar('Visión Artificial', <String>{'lab-ia-1', 'lab-ia-2'});
    verificar('Redes de Computadoras', <String>{'lab-redes'});
    verificar('Sistemas Distribuidos', <String>{'lab-redes'});
    verificar(
      'Fundamentos de Programación',
      <String>{'lab-prog-1', 'lab-prog-2', 'lab-prog-3', 'lab-prog-4'},
    );
    verificar(
      'Bases de Datos',
      <String>{'lab-sis-1', 'lab-sis-2', 'lab-sis-3', 'lab-sis-4', 'lab-sis-5', 'lab-sis-6'},
    );
  });

  test('no se generan ETS de Estancia Profesional ni de semestres > 8', () {
    for (final ExamenModel e in examenes) {
      expect(e.unidadAprendizaje, isNot('Estancia Profesional'),
          reason: 'Estancia Profesional no debe tener ETS');
      expect(e.semestre, lessThanOrEqualTo(8),
          reason: '${e.unidadAprendizaje} cae en un semestre fuera de rango: ${e.semestre}');
    }
  });

  test('las aulas generales no usan los espacios de los laboratorios', () {
    // Ninguna aula general debe tener el número de un laboratorio.
    final Iterable<String> idsGenerales = DatosSemillaEscom.salonesPorArea[AreaEts.general]!
        .map((SalonModel s) => s.id);
    for (final String labNumero in <String>['s-3004', 's-4004', 's-1104', 's-1105', 's-3013']) {
      expect(idsGenerales.contains(labNumero), isFalse);
    }
  });
}
