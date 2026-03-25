import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/domain/entities/usuario.dart';
import 'package:tb_app/domain/repositories/usuario_repository.dart';
import 'package:tb_app/domain/usecases/registrar_usuario_usecase.dart';

class MockUsuarioRepository extends Mock implements UsuarioRepository {}

class FakeUsuario extends Fake implements Usuario {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RegistrarUsuarioUseCase usecase;
  late MockUsuarioRepository mockRepository;

  setUpAll(() async {
    registerFallbackValue(FakeUsuario());

    // Mock de shared_preferences para tests
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'anon-key',
      );
    } catch (_) {
      // Si ya estaba inicializado en otro test, ignoramos
    }
  });

  setUp(() async {
    mockRepository = MockUsuarioRepository();
    usecase = RegistrarUsuarioUseCase(mockRepository);

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  });

  Future<void> cargarSesionFalsa({
    required String email,
    String userId = '11111111-1111-1111-1111-111111111111',
  }) async {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = nowSeconds + 3600;

    String b64(Map<String, dynamic> jsonMap) {
      return base64Url
          .encode(utf8.encode(jsonEncode(jsonMap)))
          .replaceAll('=', '');
    }

    final header = b64({'alg': 'HS256', 'typ': 'JWT'});

    final payload = b64({
      'sub': userId,
      'email': email,
      'role': 'authenticated',
      'exp': exp,
    });

    final fakeJwt = '$header.$payload.signature';

    final sessionJson = jsonEncode({
      'access_token': fakeJwt,
      'token_type': 'bearer',
      'expires_in': 3600,
      'expires_at': exp,
      'refresh_token': 'fake-refresh-token',
      'user': {
        'id': userId,
        'aud': 'authenticated',
        'role': 'authenticated',
        'email': email,
        'email_confirmed_at': DateTime.now().toIso8601String(),
        'phone': '',
        'confirmed_at': DateTime.now().toIso8601String(),
        'last_sign_in_at': DateTime.now().toIso8601String(),
        'app_metadata': {
          'provider': 'email',
          'providers': ['email'],
        },
        'user_metadata': {},
        'identities': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    });

    await Supabase.instance.client.auth.recoverSession(sessionJson);
  }

  group('RegistrarUsuarioUseCase', () {
    test('debe registrar usuario correctamente', () async {
      await cargarSesionFalsa(email: 'test@test.com');

      final usuarioMock = Usuario(
        id: 1,
        correoElectronico: 'test@test.com',
        contrasena: '',
        nombre: 'Kevin',
        fechaNacimiento: DateTime(2000, 1, 1),
        genero: 'Masculino',
        direccion: 'Calle 123',
        telefono: '3000000000',
        tipoDocumento: 'CC',
        numeroDocumento: '123456',
        fechaRegistro: DateTime.now(),
        ultimoLogin: DateTime.now(),
        nivelAcceso: 'Basico',
      );

      when(
        () => mockRepository.registrarUsuario(any()),
      ).thenAnswer((_) async => usuarioMock);

      final result = await usecase(
        nombre: 'Kevin',
        fechaNacimiento: DateTime(2000, 1, 1),
        genero: 'Masculino',
        tipoDocumento: 'CC',
        numeroDocumento: '123456',
        direccion: 'Calle 123',
        telefono: '3000000000',
      );

      expect(result, usuarioMock);
      verify(() => mockRepository.registrarUsuario(any())).called(1);
    });

    test('debe lanzar excepción si no hay usuario autenticado', () async {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      expect(
        () => usecase(
          nombre: 'Kevin',
          fechaNacimiento: DateTime(2000, 1, 1),
          genero: 'Masculino',
          tipoDocumento: 'CC',
          numeroDocumento: '123456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('debe construir correctamente el objeto Usuario', () async {
      await cargarSesionFalsa(email: 'test@test.com');

      late Usuario usuarioCapturado;

      when(() => mockRepository.registrarUsuario(captureAny())).thenAnswer((
        invocation,
      ) async {
        usuarioCapturado = invocation.positionalArguments[0] as Usuario;
        return usuarioCapturado;
      });

      await usecase(
        nombre: 'Kevin',
        fechaNacimiento: DateTime(2000, 1, 1),
        genero: 'Masculino',
        tipoDocumento: 'CC',
        numeroDocumento: '123456',
        direccion: 'Calle 123',
        telefono: '3000000000',
      );

      expect(usuarioCapturado.nombre, 'Kevin');
      expect(usuarioCapturado.correoElectronico, 'test@test.com');
      expect(usuarioCapturado.tipoDocumento, 'CC');
      expect(usuarioCapturado.numeroDocumento, '123456');
      expect(usuarioCapturado.nivelAcceso, 'Basico');
      expect(usuarioCapturado.contrasena, '');
    });
  });
}
