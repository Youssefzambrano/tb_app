import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/domain/usecases/cerrar_sesion_usecase.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockFlutterSecureStorage mockStorage;
  late CerrarSesionUseCase useCase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockStorage = MockFlutterSecureStorage();

    when(() => mockSupabase.auth).thenReturn(mockAuth);

    useCase = CerrarSesionUseCase(supabase: mockSupabase, storage: mockStorage);
  });

  group('CerrarSesionUseCase', () {
    test('cierra sesión y elimina credenciales almacenadas', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockStorage.delete(key: 'email')).thenAnswer((_) async {});
      when(() => mockStorage.delete(key: 'password')).thenAnswer((_) async {});

      await useCase();

      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockStorage.delete(key: 'email')).called(1);
      verify(() => mockStorage.delete(key: 'password')).called(1);
    });

    test('lanza excepción si signOut falla y no borra credenciales', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('falló signOut'));

      expect(() => useCase(), throwsA(isA<Exception>()));

      verify(() => mockAuth.signOut()).called(1);
      verifyNever(() => mockStorage.delete(key: 'email'));
      verifyNever(() => mockStorage.delete(key: 'password'));
    });
  });
}
