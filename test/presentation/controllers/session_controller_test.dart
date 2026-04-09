import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tb_app/domain/entities/usuario.dart';
import 'package:tb_app/domain/usecases/cerrar_sesion_usecase.dart';
import 'package:tb_app/presentation/controllers/session_controller.dart';
import 'package:tb_app/routes/app_routes.dart';

class MockCerrarSesionUseCase extends Mock implements CerrarSesionUseCase {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionController controller;
  late MockCerrarSesionUseCase mockCerrarSesionUseCase;

  Usuario crearUsuarioTest({
    int id = 1,
    String nombre = 'Kevin',
    String correo = 'test@test.com',
    String nivelAcceso = 'PACIENTE',
  }) {
    return Usuario(
      id: id,
      correoElectronico: correo,
      contrasena: '123456',
      nombre: nombre,
      fechaNacimiento: DateTime(2000, 1, 1),
      genero: 'M',
      direccion: 'Calle 123',
      telefono: '3000000000',
      tipoDocumento: 'CC',
      numeroDocumento: '123456789',
      fechaRegistro: DateTime.now(),
      ultimoLogin: DateTime.now(),
      nivelAcceso: nivelAcceso,
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    SessionController.resetForTest();
    mockCerrarSesionUseCase = MockCerrarSesionUseCase();
    controller = SessionController(
      cerrarSesionUseCase: mockCerrarSesionUseCase,
    );
    controller.usuarioActual = null;
  });

  group('SessionController - estado y getters', () {
    test('inicializarUsuarioActual asigna correctamente el usuario', () async {
      final usuario = crearUsuarioTest();

      await controller.inicializarUsuarioActual(usuario);

      expect(controller.usuarioActual, usuario);
    });

    test('getters devuelven valores correctos cuando hay usuario', () async {
      final usuario = crearUsuarioTest(
        id: 2,
        nombre: 'Inge',
        correo: 'inge@test.com',
      );

      await controller.inicializarUsuarioActual(usuario);

      expect(controller.idUsuario, 2);
      expect(controller.nombreUsuario, 'Inge');
      expect(controller.correoUsuario, 'inge@test.com');
    });

    test('getters devuelven valores por defecto cuando no hay usuario', () {
      expect(controller.idUsuario, isNull);
      expect(controller.nombreUsuario, 'Usuario');
      expect(controller.correoUsuario, '');
      expect(controller.nivelAcceso, 'Basico');
      expect(controller.esEnfermero, false);
      expect(controller.rutaInicioPorRol, AppRoutes.inicio);
    });

    test('singleton mantiene la misma instancia', () {
      final controller1 = SessionController(
        cerrarSesionUseCase: mockCerrarSesionUseCase,
      );
      final controller2 = SessionController(
        cerrarSesionUseCase: mockCerrarSesionUseCase,
      );

      expect(identical(controller1, controller2), true);
    });

    test('limpiar sesión manual deja usuarioActual en null', () async {
      final usuario = crearUsuarioTest();

      await controller.inicializarUsuarioActual(usuario);

      controller.usuarioActual = null;

      expect(controller.usuarioActual, isNull);
    });

    test(
      'esEnfermero retorna true cuando el nivel de acceso es enfermero',
      () async {
        final usuario = crearUsuarioTest(nivelAcceso: 'ENFERMERO');

        await controller.inicializarUsuarioActual(usuario);

        expect(controller.esEnfermero, true);
      },
    );

    test(
      'rutaInicioPorRol retorna inicioEnfermero si el usuario es enfermero',
      () async {
        final usuario = crearUsuarioTest(nivelAcceso: 'ENFERMERO');

        await controller.inicializarUsuarioActual(usuario);

        expect(controller.rutaInicioPorRol, AppRoutes.inicioEnfermero);
      },
    );

    test(
      'rutaInicioPorRol retorna inicio si el usuario no es enfermero',
      () async {
        final usuario = crearUsuarioTest(nivelAcceso: 'PACIENTE');

        await controller.inicializarUsuarioActual(usuario);

        expect(controller.rutaInicioPorRol, AppRoutes.inicio);
      },
    );
  });

  group('SessionController - cerrarSesionYRedirigir', () {
    testWidgets('cierra sesión, limpia usuario y redirige a bienvenida', (
      tester,
    ) async {
      when(() => mockCerrarSesionUseCase()).thenAnswer((_) async {});

      final usuario = crearUsuarioTest();
      await controller.inicializarUsuarioActual(usuario);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/':
                (_) => Builder(
                  builder:
                      (context) => Scaffold(
                        body: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.cerrarSesionYRedirigir(context);
                            },
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                      ),
                ),
            '/bienvenida':
                (_) => const Scaffold(body: Text('Pantalla Bienvenida')),
          },
        ),
      );

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockCerrarSesionUseCase()).called(1);
      expect(controller.usuarioActual, isNull);
      expect(find.text('Pantalla Bienvenida'), findsOneWidget);
    });

    testWidgets('muestra snackbar si ocurre error al cerrar sesión', (
      tester,
    ) async {
      when(
        () => mockCerrarSesionUseCase(),
      ).thenThrow(Exception('falló el cierre'));

      final usuario = crearUsuarioTest();
      await controller.inicializarUsuarioActual(usuario);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/':
                (_) => Builder(
                  builder:
                      (context) => Scaffold(
                        body: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.cerrarSesionYRedirigir(context);
                            },
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                      ),
                ),
            '/bienvenida':
                (_) => const Scaffold(body: Text('Pantalla Bienvenida')),
          },
        ),
      );

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockCerrarSesionUseCase()).called(1);
      expect(controller.usuarioActual, isNotNull);
      expect(find.textContaining('Error al cerrar sesión'), findsOneWidget);
    });
  });
}
