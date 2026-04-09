import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/bienvenida/pages/bienvenida_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla de bienvenida', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BienvenidaPantalla()));

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);
  });

  testWidgets('tap en "Comenzar" no rompe la UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BienvenidaPantalla()));

    await tester.tap(find.text('Comenzar'));
    await tester.pump();

    expect(find.byType(BienvenidaPantalla), findsOneWidget);
  });
}
