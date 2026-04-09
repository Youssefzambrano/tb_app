import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/tratamiento/pages/tratamiento_terminado_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de tratamiento terminado', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TratamientoTerminadoPantalla()),
    );

    // Texto principal
    expect(find.text('¡Tratamiento Completado!'), findsOneWidget);

    // Texto secundario
    expect(
      find.textContaining('Has completado tu tratamiento'),
      findsOneWidget,
    );

    // Botón
    expect(find.text('Finalizar'), findsOneWidget);

    // Imagen
    expect(find.byType(Image), findsOneWidget);
  });
}
