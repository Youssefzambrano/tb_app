import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/tratamiento/pages/exito_toma_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de éxito de toma', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExitoTomaPantalla()));

    // Texto principal
    expect(find.text('¡Toma registrada!'), findsOneWidget);

    // Texto secundario
    expect(
      find.textContaining('Ya registraste la toma del día'),
      findsOneWidget,
    );

    // Botón
    expect(find.text('Entendido'), findsOneWidget);

    // Imagen
    expect(find.byType(Image), findsOneWidget);
  });
}
