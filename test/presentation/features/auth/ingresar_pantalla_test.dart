import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/presentation/controllers/session_controller.dart';
import 'package:tb_app/presentation/features/auth/pages/ingresar_pantalla.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  setUp(() {
    SessionController.resetForTest();
  });

  Future<void> pumpPantalla(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IngresarPantalla()));
    await tester.pumpAndSettle();
  }

  testWidgets('renderiza correctamente la pantalla de ingreso', (tester) async {
    await pumpPantalla(tester);

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Correo o usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('muestra validación cuando los campos están vacíos', (
    tester,
  ) async {
    await pumpPantalla(tester);

    final botonIngresar = find.text('Ingresar');
    await tester.ensureVisible(botonIngresar);
    await tester.tap(botonIngresar);
    await tester.pump();

    expect(find.text('Campo requerido'), findsNWidgets(2));
  });

  testWidgets('permite mostrar y ocultar la contraseña', (tester) async {
    await pumpPantalla(tester);

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('permite escribir en los campos del formulario', (tester) async {
    await pumpPantalla(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'usuario@correo.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.pump();

    expect(find.text('usuario@correo.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
  });

  testWidgets('el enlace de recuperar contraseña está visible', (tester) async {
    await pumpPantalla(tester);

    final linkFinder = find.text('¿Olvidaste tu contraseña?');
    await tester.ensureVisible(linkFinder);

    expect(linkFinder, findsOneWidget);
  });
}
