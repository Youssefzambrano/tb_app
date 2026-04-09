import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/iniciar_tratamiento_usecase.dart';
import 'package:tb_app/presentation/controllers/iniciar_tratamiento_controller.dart';
import 'package:tb_app/routes/app_routes.dart';

class MockIniciarTratamientoUseCase extends Mock
    implements IniciarTratamientoUseCase {}

class TestHost extends StatelessWidget {
  final VoidCallback onPressed;

  const TestHost({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(onPressed: onPressed, child: const Text('start')),
    );
  }
}

void main() {
  late IniciarTratamientoController controller;
  late MockIniciarTratamientoUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockIniciarTratamientoUseCase();
    controller = IniciarTratamientoController(
      iniciarTratamientoUseCase: mockUseCase,
    );
  });

  testWidgets('flujo exitoso navega correctamente', (tester) async {
    when(() => mockUseCase(idPaciente: 1)).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        routes: {AppRoutes.inicio: (_) => const Scaffold(body: Text('inicio'))},
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.iniciarTratamientoYRedirigir(
                  context: context,
                  idPaciente: 1,
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('start'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => mockUseCase(idPaciente: 1)).called(1);
    expect(find.text('inicio'), findsOneWidget);
  });

  testWidgets('muestra snackbar cuando hay error', (tester) async {
    when(() => mockUseCase(idPaciente: 1)).thenThrow(Exception('fallo'));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.iniciarTratamientoYRedirigir(
                  context: context,
                  idPaciente: 1,
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('start'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al iniciar tratamiento'), findsOneWidget);
  });
}
