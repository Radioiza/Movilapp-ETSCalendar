import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_ets/features/exams/domain/entities/examen.dart';
import 'package:gestion_ets/features/exams/presentation/widgets/tabla_resultados_examenes.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/datos_prueba.dart';

/// Módulo Público · Visualización Dinámica: la tabla de resultados debe mostrar
/// Materia, Fecha, Turno, Salón y Profesor evaluador, y permitir marcar
/// favoritos / abrir el detalle.
Future<void> _montar(
  WidgetTester tester, {
  required List<Examen> examenes,
  required Set<String> favoritos,
  required ValueChanged<Examen> onAlternar,
  required ValueChanged<Examen> onDetalle,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TablaResultadosExamenes(
          examenes: examenes,
          favoritos: favoritos,
          onAlternarFavorito: onAlternar,
          onAbrirDetalle: onDetalle,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_MX');
  });

  testWidgets('muestra las columnas requeridas y los datos del examen',
      (WidgetTester tester) async {
    final Examen examen = examenDePrueba(
      unidadAprendizaje: 'Cálculo',
      salonNombre: 'Edificio 1 · 101',
      profesorEvaluador: 'Ada Lovelace',
      turno: Turno.matutino,
    );

    await _montar(
      tester,
      examenes: <Examen>[examen],
      favoritos: <String>{},
      onAlternar: (_) {},
      onDetalle: (_) {},
    );

    // Encabezados de columna
    for (final String col in <String>[
      'Materia',
      'Fecha',
      'Turno',
      'Salón',
      'Profesor evaluador',
    ]) {
      expect(find.text(col), findsOneWidget, reason: 'Falta la columna $col');
    }

    // Datos de la fila
    expect(find.text('Cálculo'), findsOneWidget);
    expect(find.text('Edificio 1 · 101'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Matutino'), findsOneWidget);
  });

  testWidgets('el botón de guardar dispara onAlternarFavorito',
      (WidgetTester tester) async {
    Examen? alternado;
    final Examen examen = examenDePrueba(id: 'e1');

    await _montar(
      tester,
      examenes: <Examen>[examen],
      favoritos: <String>{},
      onAlternar: (Examen e) => alternado = e,
      onDetalle: (_) {},
    );

    // La tabla se desplaza horizontalmente; aseguramos que el botón de
    // guardar quede dentro del viewport antes de tocarlo (como haría el
    // usuario en una pantalla angosta).
    await tester.ensureVisible(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pump();

    expect(alternado, isNotNull);
    expect(alternado!.id, 'e1');
  });

  testWidgets('un examen favorito muestra el ícono marcado',
      (WidgetTester tester) async {
    final Examen examen = examenDePrueba(id: 'e1');

    await _montar(
      tester,
      examenes: <Examen>[examen],
      favoritos: <String>{'e1'},
      onAlternar: (_) {},
      onDetalle: (_) {},
    );

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);
  });
}
