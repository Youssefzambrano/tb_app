import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/domain/usecases/iniciar_tratamiento_usecase.dart';
import 'package:tb_app/presentation/controllers/iniciar_tratamiento_controller_helper.dart';
import 'package:tb_app/routes/app_routes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockIniciarTratamientoUseCase extends Mock
    implements IniciarTratamientoUseCase {}

class TestHost extends StatelessWidget {
  final VoidCallback onPressed;

  const TestHost({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(onPressed: onPressed, child: const Text('iniciar')),
    );
  }
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockIniciarTratamientoUseCase mockUseCase;
  late IniciarTratamientoController controller;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUseCase = MockIniciarTratamientoUseCase();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
  });

  testWidgets('muestra snackbar si no hay usuario', (tester) async {
    when(() => mockAuth.currentUser).thenReturn(null);

    controller = IniciarTratamientoController(
      supabase: mockSupabase,
      iniciarTratamientoUseCase: mockUseCase,
      obtenerIdUsuarioPorCorreo: (_, __) async => 7,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.iniciarTratamientoDesdeSesion(context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pump();

    expect(find.text('No se pudo obtener el usuario actual.'), findsOneWidget);
  });

  testWidgets('muestra snackbar si el usuario no tiene email', (tester) async {
    final mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn(null);

    controller = IniciarTratamientoController(
      supabase: mockSupabase,
      iniciarTratamientoUseCase: mockUseCase,
      obtenerIdUsuarioPorCorreo: (_, __) async => 7,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.iniciarTratamientoDesdeSesion(context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pump();

    expect(find.text('No se pudo obtener el usuario actual.'), findsOneWidget);
  });

  testWidgets('inicia tratamiento y navega a inicio en flujo exitoso', (
    tester,
  ) async {
    final mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('test@test.com');
    when(() => mockUseCase(idPaciente: 7)).thenAnswer((_) async {});

    controller = IniciarTratamientoController(
      supabase: mockSupabase,
      iniciarTratamientoUseCase: mockUseCase,
      obtenerIdUsuarioPorCorreo: (_, __) async => 7,
    );

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.inicio:
              (_) => const Scaffold(body: Text('Pantalla inicio')),
        },
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.iniciarTratamientoDesdeSesion(context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => mockUseCase(idPaciente: 7)).called(1);
    expect(find.text('Pantalla inicio'), findsOneWidget);
  });

  testWidgets('muestra snackbar si falla obtener id de usuario', (
    tester,
  ) async {
    final mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('test@test.com');

    controller = IniciarTratamientoController(
      supabase: mockSupabase,
      iniciarTratamientoUseCase: mockUseCase,
      obtenerIdUsuarioPorCorreo: (_, __) async {
        throw Exception('falló consulta');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.iniciarTratamientoDesdeSesion(context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al iniciar tratamiento'), findsOneWidget);
  });

  testWidgets('muestra snackbar si falla el use case', (tester) async {
    final mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('test@test.com');
    when(
      () => mockUseCase(idPaciente: 7),
    ).thenThrow(Exception('falló use case'));

    controller = IniciarTratamientoController(
      supabase: mockSupabase,
      iniciarTratamientoUseCase: mockUseCase,
      obtenerIdUsuarioPorCorreo: (_, __) async => 7,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.iniciarTratamientoDesdeSesion(context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al iniciar tratamiento'), findsOneWidget);
  });
}
