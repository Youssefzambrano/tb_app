import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/legal/pages/terminos_condiciones_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de términos y condiciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TerminosCondicionesPantalla()),
    );

    // AppBar
    expect(find.text('Términos y Condiciones'), findsOneWidget);

    // Título principal
    expect(find.text('Términos y Condiciones de Uso'), findsOneWidget);

    // Texto largo (validamos parcialmente)
    expect(
      find.textContaining('Evita TB recopila algunos datos'),
      findsOneWidget,
    );

    // Verifica que existe scroll
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
