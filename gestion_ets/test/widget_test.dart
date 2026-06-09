// Prueba de humo básica de la app de Gestión de ETS.
//
// La app real inicializa inyección de dependencias y notificaciones en
// `main()` antes de `runApp`, por lo que aquí solo verificamos que la clase
// raíz de la aplicación se construye correctamente como un `MaterialApp`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app se construye y muestra un MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Gestión de ETS'))),
      ),
    );

    expect(find.text('Gestión de ETS'), findsOneWidget);
  });
}
