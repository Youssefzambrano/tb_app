import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tb_app/domain/usecases/iniciar_sesion_usecase.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late IniciarSesionUseCase usecase;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockStorage = MockFlutterSecureStorage();

    when(() => mockSupabase.auth).thenReturn(mockAuth);

    when(
      () => mockAuth.signOut(scope: SignOutScope.local),
    ).thenAnswer((_) async {});

    usecase = IniciarSesionUseCase(
      supabase: mockSupabase,
      storage: mockStorage,
    );
  });

  group('IniciarSesionUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('debe iniciar sesión cuando el correo está confirmado', () async {
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('123');
      when(
        () => mockUser.emailConfirmedAt,
      ).thenReturn(DateTime.now().toIso8601String());
      when(() => mockResponse.user).thenReturn(mockUser);

      when(
        () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
      ).thenAnswer((_) async => mockResponse);

      await usecase.call(email: tEmail, password: tPassword);

      verify(() => mockAuth.signOut(scope: SignOutScope.local)).called(1);
      verify(
        () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
      ).called(1);
    });

    test(
      'debe lanzar una Exception si el usuario no ha confirmado su correo',
      () async {
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('123');
        when(() => mockUser.emailConfirmedAt).thenReturn(null);
        when(() => mockResponse.user).thenReturn(mockUser);

        when(
          () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => mockResponse);

        await expectLater(
          () => usecase.call(email: tEmail, password: tPassword),
          throwsA(isA<Exception>()),
        );

        verify(() => mockAuth.signOut(scope: SignOutScope.local)).called(1);
        verify(
          () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
        ).called(1);
      },
    );
  });
}
