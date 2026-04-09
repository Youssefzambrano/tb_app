import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/auth/pages/recuperar_contrasena_pantalla.dart';

void main() {
  Future<void> pumpPantalla(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RecuperarContrasenaPantalla()),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('renderiza correctamente recuperar contraseña', (tester) async {
    await pumpPantalla(tester);

    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(find.text('Enviar instrucciones'), findsOneWidget);
  });

  testWidgets('valida campo vacío', (tester) async {
    await pumpPantalla(tester);

    final boton = find.text('Enviar instrucciones');

    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Campo requerido'), findsOneWidget);
  });

  testWidgets('valida correo inválido', (tester) async {
    await pumpPantalla(tester);

    await tester.enterText(find.byType(TextFormField), 'correo_invalido');

    final boton = find.text('Enviar instrucciones');

    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Correo no válido'), findsOneWidget);
  });

  testWidgets('botón volver no rompe la UI', (tester) async {
    await pumpPantalla(tester);

    final boton = find.text('Volver');

    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.byType(RecuperarContrasenaPantalla), findsOneWidget);
  });
}
