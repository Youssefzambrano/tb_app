import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/data/datasources/remote/supabase/auth_supabase_service.dart';
import 'package:tb_app/data/models/usuario_model.dart';
import 'package:tb_app/data/repositories_impl/usuario_repository_impl.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockDynamicFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockAuthService extends Mock implements AuthSupabaseService {}

class FakeAwaitableFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final T value;

  FakeAwaitableFilterBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future<T>.value(value).then<R>(onValue, onError: onError);
  }
}

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

class FakeMaybeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? value;

  FakeMaybeSingleBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap? value) onValue, {
    Function? onError,
  }) {
    return Future<PostgrestMap?>.value(
      value,
    ).then<R>(onValue, onError: onError);
  }
}

void main() {
  late UsuarioRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;
  late MockAuthService mockAuth;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockAuthService();

    repository = UsuarioRepositoryImpl(
      supabase: mockSupabase,
      authService: mockAuth,
    );
  });

  final usuario = UsuarioModel(
    id: 1,
    correoElectronico: 'test@test.com',
    contrasena: '123456',
    nombre: 'Kevin',
    fechaNacimiento: DateTime(2000, 1, 1),
    genero: 'Masculino',
    direccion: 'Calle 123',
    telefono: '3000000000',
    tipoDocumento: 'CC',
    numeroDocumento: '123456',
    fechaRegistro: DateTime(2024, 1, 1),
    ultimoLogin: DateTime(2024, 1, 1),
    nivelAcceso: 'Basico',
  );

  final usuarioMap = {
    'id': 1,
    'correo_electronico': 'test@test.com',
    'contraseña': '123456',
    'nombre': 'Kevin',
    'fecha_nacimiento': '2000-01-01T00:00:00.000',
    'genero': 'Masculino',
    'direccion': 'Calle 123',
    'telefono': '3000000000',
    'tipo_documento': 'CC',
    'numero_documento': '123456',
    'fecha_registro': '2024-01-01T00:00:00.000',
    'ultimo_login': '2024-01-01T00:00:00.000',
    'nivel_acceso': 'Basico',
  };

  group('UsuarioRepositoryImpl', () {
    test('registrarUsuario inserta y retorna usuario', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(
        () => qb.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));
      when(() => qb.select()).thenAnswer((_) => fb);
      when(
        () => fb.eq('correo_electronico', usuario.correoElectronico),
      ).thenAnswer((_) => fb);
      when(() => fb.single()).thenAnswer((_) => FakeSingleBuilder(usuarioMap));

      final result = await repository.registrarUsuario(usuario);

      expect(result.correoElectronico, usuario.correoElectronico);
      expect(result.nombre, 'Kevin');
    });

    test('registrarUsuario lanza excepción si falla el insert', () async {
      final qb = MockQueryBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.insert(any())).thenThrow(Exception('db error'));

      expect(
        () => repository.registrarUsuario(usuario),
        throwsA(isA<Exception>()),
      );
    });

    test('iniciarSesion autentica y retorna usuario', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.select()).thenAnswer((_) => fb);
      when(
        () => fb.eq('correo_electronico', usuario.correoElectronico),
      ).thenAnswer((_) => fb);
      when(() => fb.single()).thenAnswer((_) => FakeSingleBuilder(usuarioMap));

      final result = await repository.iniciarSesion(
        usuario.correoElectronico,
        usuario.contrasena,
      );

      expect(result.nombre, 'Kevin');
      verify(
        () => mockAuth.signInWithEmail(
          email: usuario.correoElectronico,
          password: usuario.contrasena,
        ),
      ).called(1);
    });

    test('cerrarSesion llama authService', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await repository.cerrarSesion();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('enviarCorreoRecuperacion llama resetPassword', () async {
      when(() => mockAuth.resetPassword(any())).thenAnswer((_) async {});

      await repository.enviarCorreoRecuperacion('test@test.com');

      verify(() => mockAuth.resetPassword('test@test.com')).called(1);
    });

    test('obtenerUsuarioPorId retorna usuario', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.select()).thenAnswer((_) => fb);
      when(() => fb.eq('id', 1)).thenAnswer((_) => fb);
      when(
        () => fb.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(usuarioMap));

      final result = await repository.obtenerUsuarioPorId(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.nombre, 'Kevin');
    });

    test('obtenerUsuarioPorId retorna null si no existe', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.select()).thenAnswer((_) => fb);
      when(() => fb.eq('id', 1)).thenAnswer((_) => fb);
      when(
        () => fb.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      final result = await repository.obtenerUsuarioPorId(1);

      expect(result, isNull);
    });

    test('actualizarUsuario ejecuta update', () async {
      final qb = MockQueryBuilder();
      final fb = MockDynamicFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.update(any())).thenAnswer((_) => fb);
      when(
        () => fb.eq('id', 1),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.actualizarUsuario(usuario);

      verify(() => qb.update(any())).called(1);
    });

    test('obtenerUsuariosPorRol retorna lista', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.select()).thenAnswer((_) => fb);
      when(() => fb.eq('nivel_acceso', 'Basico')).thenAnswer(
        (_) => FakeAwaitableFilterBuilder<PostgrestList>([usuarioMap]),
      );

      final result = await repository.obtenerUsuariosPorRol('Basico');

      expect(result.length, 1);
      expect(result.first.nombre, 'Kevin');
    });

    test('obtenerRolUsuario retorna rol', () async {
      final qb = MockQueryBuilder();
      final fb = MockFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.select('nivel_acceso')).thenAnswer((_) => fb);
      when(() => fb.eq('id', 1)).thenAnswer((_) => fb);
      when(
        () => fb.single(),
      ).thenAnswer((_) => FakeSingleBuilder({'nivel_acceso': 'Basico'}));

      final result = await repository.obtenerRolUsuario(1);

      expect(result, 'Basico');
    });

    test('eliminarUsuario ejecuta delete', () async {
      final qb = MockQueryBuilder();
      final fb = MockDynamicFilterBuilder();

      when(() => mockSupabase.from('usuario')).thenAnswer((_) => qb);
      when(() => qb.delete()).thenAnswer((_) => fb);
      when(
        () => fb.eq('id', 1),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.eliminarUsuario(1);

      verify(() => qb.delete()).called(1);
    });

    test('enviarCorreoVerificacion lanza UnimplementedError', () {
      expect(
        () => repository.enviarCorreoVerificacion('test@test.com'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('cambiarContrasena lanza UnimplementedError', () {
      expect(
        () => repository.cambiarContrasena(1, 'nueva123'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
