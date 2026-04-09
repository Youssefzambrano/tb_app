import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/autochequeo/pages/chequeo_negativo_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de chequeo negativo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChequeoNegativoPantalla()));

    // Texto principal
    expect(find.text('¡Sin síntomas!'), findsOneWidget);

    // Texto secundario
    expect(find.textContaining('tu compromiso es fundamental'), findsOneWidget);

    // Botón
    expect(find.text('Volver al inicio'), findsOneWidget);

    // Imagen
    expect(find.byType(Image), findsOneWidget);
  });
}
