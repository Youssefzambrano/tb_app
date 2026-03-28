import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/domain/entities/usuario.dart';
import 'package:tb_app/presentation/controllers/session_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionController controller;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-key',
      );
    } catch (_) {
      // Si ya fue inicializado por otro test, no pasa nada.
    }
  });

  setUp(() {
    controller = SessionController();
    controller.usuarioActual = null;
  });

  Usuario crearUsuarioTest({
    int id = 1,
    String nombre = 'Kevin',
    String correo = 'test@test.com',
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
      nivelAcceso: 'PACIENTE',
    );
  }

  group('SessionController', () {
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
    });

    test('singleton mantiene la misma instancia', () {
      final controller1 = SessionController();
      final controller2 = SessionController();

      expect(identical(controller1, controller2), true);
    });

    test('limpiar sesión manual deja usuarioActual en null', () async {
      final usuario = crearUsuarioTest();

      await controller.inicializarUsuarioActual(usuario);

      controller.usuarioActual = null;

      expect(controller.usuarioActual, isNull);
    });
  });
}
