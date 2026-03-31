import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/domain/entities/usuario.dart';
import 'package:tb_app/domain/usecases/iniciar_sesion_usecase.dart';
import 'package:tb_app/presentation/controllers/login_controller.dart';
import 'package:tb_app/presentation/controllers/session_controller.dart';

class MockIniciarSesionUseCase extends Mock implements IniciarSesionUseCase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSessionController extends Mock implements SessionController {}

class FakeUsuario extends Fake implements Usuario {}

class FakeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap value;

  FakeSingleBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap value) onValue, {
    Function? onError,
  }) {
    return Future<PostgrestMap>.value(value).then<R>(onValue, onError: onError);
  }
}

class FakeLoginFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  final PostgrestMap userMap;

  FakeLoginFilterBuilder(this.userMap);

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object? value) {
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return FakeSingleBuilder(userMap);
  }
}

class FakeLoginQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final PostgrestMap userMap;

  FakeLoginQueryBuilder(this.userMap);

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    return FakeLoginFilterBuilder(userMap);
  }
}

class TestLoginButton extends StatelessWidget {
  final LoginController controller;
  final String email;
  final String password;

  const TestLoginButton({
    super.key,
    required this.controller,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          controller.iniciarSesion(
            context: context,
            email: email,
            password: password,
          );
        },
        child: const Text('login'),
      ),
    );
  }
}

void main() {
  late LoginController controller;
  late MockIniciarSesionUseCase mockUseCase;
  late MockSupabaseClient mockSupabase;
  late MockSessionController mockSession;

  final usuarioMap = {
    'id': 1,
    'correo_electronico': 'test@test.com',
    'contraseña': '1234',
    'nombre': 'Test User',
    'fecha_nacimiento': DateTime(2000, 1, 1).toIso8601String(),
    'genero': 'Masculino',
    'direccion': null,
    'telefono': null,
    'tipo_documento': 'CC',
    'numero_documento': '123456789',
    'fecha_registro': DateTime.now().toIso8601String(),
    'ultimo_login': DateTime.now().toIso8601String(),
    'nivel_acceso': 'paciente',
  };

  setUpAll(() {
    registerFallbackValue(FakeUsuario());
  });

  setUp(() {
    mockUseCase = MockIniciarSesionUseCase();
    mockSupabase = MockSupabaseClient();
    mockSession = MockSessionController();

    controller = LoginController(
      iniciarSesionUseCase: mockUseCase,
      supabase: mockSupabase,
      sessionController: mockSession,
    );
  });

  group('LoginController', () {
    testWidgets('login exitoso navega correctamente', (tester) async {
      when(
        () => mockUseCase(email: 'test@test.com', password: '1234'),
      ).thenAnswer((_) async {});

      when(
        () => mockSupabase.from('usuario'),
      ).thenAnswer((_) => FakeLoginQueryBuilder(usuarioMap));

      when(
        () => mockSession.inicializarUsuarioActual(any()),
      ).thenAnswer((_) async {});
      when(() => mockSession.rutaInicioPorRol).thenReturn('/home');

      await tester.pumpWidget(
        MaterialApp(
          routes: {'/home': (_) => const Scaffold(body: Text('home'))},
          home: TestLoginButton(
            controller: controller,
            email: 'test@test.com',
            password: '1234',
          ),
        ),
      );

      await tester.tap(find.text('login'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(
        () => mockUseCase(email: 'test@test.com', password: '1234'),
      ).called(1);

      verify(() => mockSupabase.from('usuario')).called(1);
      verify(() => mockSession.inicializarUsuarioActual(any())).called(1);

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('login con AuthException muestra snackbar', (tester) async {
      when(
        () => mockUseCase(email: 'test@test.com', password: '1234'),
      ).thenThrow(AuthException('credenciales invalidas'));

      await tester.pumpWidget(
        MaterialApp(
          home: TestLoginButton(
            controller: controller,
            email: 'test@test.com',
            password: '1234',
          ),
        ),
      );

      await tester.tap(find.text('login'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Correo o contrasena incorrectos'), findsOneWidget);
    });

    testWidgets('login con error general muestra snackbar', (tester) async {
      when(
        () => mockUseCase(email: 'test@test.com', password: '1234'),
      ).thenThrow(Exception('fallo general'));

      await tester.pumpWidget(
        MaterialApp(
          home: TestLoginButton(
            controller: controller,
            email: 'test@test.com',
            password: '1234',
          ),
        ),
      );

      await tester.tap(find.text('login'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Ocurrio un error. Intenta nuevamente.'),
        findsOneWidget,
      );
    });
  });
}
