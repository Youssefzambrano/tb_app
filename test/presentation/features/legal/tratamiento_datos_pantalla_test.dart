import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/legal/pages/tratamiento_datos_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de tratamiento de datos', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TratamientoDatosPantalla()),
    );

    // AppBar
    expect(find.text('Tratamiento de Datos'), findsOneWidget);

    // Título principal
    expect(find.text('Política de Tratamiento de Datos'), findsOneWidget);

    // Texto largo
    expect(
      find.textContaining('Evita TB se compromete a proteger la privacidad'),
      findsOneWidget,
    );

    // Contenedor principal
    expect(find.byType(Container), findsWidgets);

    // Scroll
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
