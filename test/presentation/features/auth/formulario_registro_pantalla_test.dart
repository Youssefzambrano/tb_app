import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/auth/pages/formulario_registro_pantalla.dart';

class FakeAuthService {
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Fake: no hace nada
  }
}

void main() {
  Future<void> pumpPantalla(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: RegistroPantalla(authService: FakeAuthService())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renderiza correctamente la pantalla de registro', (
    tester,
  ) async {
    await pumpPantalla(tester);

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Registrarme'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('valida campos vacíos', (tester) async {
    await pumpPantalla(tester);

    expect(find.text('Campo requerido'), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final boton = find.widgetWithText(ElevatedButton, 'Registrarme');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Campo requerido'), findsNWidgets(4));
  });

  testWidgets('valida contraseña corta', (tester) async {
    await pumpPantalla(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Kevin');
    await tester.enterText(find.byType(TextFormField).at(1), 'correo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.enterText(find.byType(TextFormField).at(3), '123');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final boton = find.widgetWithText(ElevatedButton, 'Registrarme');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
  });

  testWidgets('valida confirmación de contraseña', (tester) async {
    await pumpPantalla(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Kevin');
    await tester.enterText(find.byType(TextFormField).at(1), 'correo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '654321');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final boton = find.widgetWithText(ElevatedButton, 'Registrarme');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('No coincide'), findsOneWidget);
  });

  testWidgets('checkbox habilita botón', (tester) async {
    await pumpPantalla(tester);

    final botonFinder = find.widgetWithText(ElevatedButton, 'Registrarme');

    ElevatedButton boton = tester.widget<ElevatedButton>(botonFinder);
    expect(boton.onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    boton = tester.widget<ElevatedButton>(botonFinder);
    expect(boton.onPressed, isNotNull);
  });

  testWidgets('toggle visibilidad contraseña', (tester) async {
    await pumpPantalla(tester);

    expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('permite escribir en todos los campos', (tester) async {
    await pumpPantalla(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Kevin');
    await tester.enterText(find.byType(TextFormField).at(1), 'correo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    await tester.pump();

    expect(find.text('Kevin'), findsOneWidget);
    expect(find.text('correo@test.com'), findsOneWidget);
  });
}
