import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/autochequeo/pages/chequeo_positivo_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de chequeo positivo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChequeoPositivoPantalla()));

    // Texto principal
    expect(find.text('¡Gracias por tu respuesta!'), findsOneWidget);

    // Texto secundario
    expect(find.textContaining('presentas síntomas'), findsOneWidget);

    // Botón
    expect(find.text('Ir al inicio'), findsOneWidget);

    // Imagen
    expect(find.byType(Image), findsOneWidget);
  });
}
