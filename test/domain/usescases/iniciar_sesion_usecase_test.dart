import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tb_app/domain/usecases/iniciar_sesion_usecase.dart';

// Creamos los Mocks necesarios
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {} // Para el auth

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

    // Configuramos el cliente de Supabase para que devuelva el mock de Auth
    when(() => mockSupabase.auth).thenReturn(mockAuth);

    usecase = IniciarSesionUseCase(
      supabase: mockSupabase,
      storage: mockStorage,
    );
  });

  group('IniciarSesionUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test(
      'debe iniciar sesión y guardar credenciales cuando el correo está confirmado',
      () async {
        // Arrange (Organizar)
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(
          () => mockUser.emailConfirmedAt,
        ).thenReturn(DateTime.now().toString());
        when(() => mockResponse.user).thenReturn(mockUser);

        when(
          () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => mockResponse);

        // Simulamos que el guardado en storage funciona bien
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // Act (Actuar)
        await usecase.call(email: tEmail, password: tPassword);

        // Assert (Verificar)
        verify(
          () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
        ).called(1);
        verify(() => mockStorage.write(key: 'email', value: tEmail)).called(1);
        verify(
          () => mockStorage.write(key: 'password', value: tPassword),
        ).called(1);
      },
    );

    test(
      'debe lanzar una Exception si el usuario no ha confirmado su correo',
      () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(
          () => mockUser.emailConfirmedAt,
        ).thenReturn(null); // Correo NO confirmado
        when(() => mockResponse.user).thenReturn(mockUser);

        when(
          () => mockAuth.signInWithPassword(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => usecase.call(email: tEmail, password: tPassword),
          throwsA(isA<Exception>()),
        );

        // Verificamos que NUNCA se guardó nada en storage si el correo no estaba confirmado
        verifyNever(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      },
    );
  });
}
