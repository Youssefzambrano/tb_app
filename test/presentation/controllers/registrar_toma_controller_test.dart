import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/domain/usecases/registrar_toma_usecase.dart';
import 'package:tb_app/presentation/controllers/registrar_toma_controller.dart';
import 'package:tb_app/presentation/controllers/session_controller.dart';
import 'package:tb_app/presentation/features/tratamiento/pages/fase_intensiva_terminada_pantalla.dart';
import 'package:tb_app/presentation/features/tratamiento/pages/tratamiento_terminado_pantalla.dart';
import 'package:tb_app/routes/app_routes.dart';

class MockRegistrarTomaUseCase extends Mock implements RegistrarTomaUseCase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSessionController extends Mock implements SessionController {}

class TestHost extends StatelessWidget {
  final VoidCallback onPressed;

  const TestHost({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(onPressed: onPressed, child: const Text('tomar')),
    );
  }
}

class FakeRegistrarTomaController extends RegistrarTomaController {
  FakeRegistrarTomaController({
    required super.registrarTomaUseCase,
    required super.supabase,
    required super.sessionController,
  });

  Map<String, dynamic>? tratamientoMock;
  List<dynamic> dosisHoyMock = [];
  int medicamentoIdMock = 10;
  int totalDosisTomadasMock = 1;

  bool actualizarPendientesLlamado = false;
  bool activarFase2Llamado = false;
  bool completarTratamientoLlamado = false;

  bool lanzarErrorEnTratamiento = false;
  bool lanzarErrorEnMedicamento = false;

  @override
  Future<Map<String, dynamic>> obtenerTratamientoEnCurso(int idUsuario) async {
    if (lanzarErrorEnTratamiento) {
      throw Exception('falló tratamiento');
    }
    if (tratamientoMock == null) {
      throw Exception('Sin tratamiento mock');
    }
    return tratamientoMock!;
  }

  @override
  Future<List<dynamic>> obtenerDosisDeHoy(int idTratamiento) async {
    return dosisHoyMock;
  }

  @override
  Future<int> obtenerMedicamentoId(bool fase1Activa, int idTratamiento) async {
    if (lanzarErrorEnMedicamento) {
      throw Exception('falló medicamento');
    }
    return medicamentoIdMock;
  }

  @override
  Future<void> actualizarDosisPendientes(
    int idTratamiento,
    int nuevaDosisPendiente,
  ) async {
    actualizarPendientesLlamado = true;
  }

  @override
  Future<int> obtenerTotalDosisTomadas(int idTratamiento) async {
    return totalDosisTomadasMock;
  }

  @override
  Future<void> activarFase2(int idTratamiento) async {
    activarFase2Llamado = true;
  }

  @override
  Future<void> completarTratamiento(int idTratamiento) async {
    completarTratamientoLlamado = true;
  }
}

void main() {
  late FakeRegistrarTomaController controller;
  late MockRegistrarTomaUseCase mockUseCase;
  late MockSupabaseClient mockSupabase;
  late MockSessionController mockSession;

  setUp(() {
    mockUseCase = MockRegistrarTomaUseCase();
    mockSupabase = MockSupabaseClient();
    mockSession = MockSessionController();

    controller = FakeRegistrarTomaController(
      registrarTomaUseCase: mockUseCase,
      supabase: mockSupabase,
      sessionController: mockSession,
    );
  });

  testWidgets('muestra snackbar si ocurre error general', (tester) async {
    when(() => mockSession.idUsuario).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al registrar la toma'), findsOneWidget);
  });

  testWidgets('muestra snackbar si ya registró dosis hoy', (tester) async {
    when(() => mockSession.idUsuario).thenReturn(1);

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': true,
      'fase2_continuacion_activa': false,
      'dosis_pendientes': 20,
    };
    controller.dosisHoyMock = [
      {'id': 1},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Ya registraste la dosis de hoy. Solo se permite una dosis por día.',
      ),
      findsOneWidget,
    );

    verifyNever(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    );
  });

  testWidgets('registra toma y navega a ruta de éxito', (tester) async {
    when(() => mockSession.idUsuario).thenReturn(1);

    when(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    ).thenAnswer((_) async {});

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': true,
      'fase2_continuacion_activa': false,
      'dosis_pendientes': 20,
    };
    controller.dosisHoyMock = [];
    controller.medicamentoIdMock = 7;
    controller.totalDosisTomadasMock = 10;

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.exitoToma:
              (_) => const Scaffold(body: Text('Pantalla éxito toma')),
        },
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(
      () => mockUseCase(
        idTratamientoPaciente: 100,
        idMedicamento: 7,
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: 'Tomada',
      ),
    ).called(1);

    expect(controller.actualizarPendientesLlamado, true);
    expect(find.text('Pantalla éxito toma'), findsOneWidget);
  });

  testWidgets('activa fase 2 cuando completa 56 dosis en fase intensiva', (
    tester,
  ) async {
    when(() => mockSession.idUsuario).thenReturn(1);

    when(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    ).thenAnswer((_) async {});

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': true,
      'fase2_continuacion_activa': false,
      'dosis_pendientes': 5,
    };
    controller.dosisHoyMock = [];
    controller.totalDosisTomadasMock = 56;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.activarFase2Llamado, true);
    expect(find.byType(FaseIntensivaTerminadaPantalla), findsOneWidget);
  });

  testWidgets('completa tratamiento cuando ya no quedan dosis pendientes', (
    tester,
  ) async {
    when(() => mockSession.idUsuario).thenReturn(1);

    when(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    ).thenAnswer((_) async {});

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': false,
      'fase2_continuacion_activa': true,
      'dosis_pendientes': 1,
    };
    controller.dosisHoyMock = [];
    controller.totalDosisTomadasMock = 30;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.completarTratamientoLlamado, true);
    expect(find.byType(TratamientoTerminadoPantalla), findsOneWidget);
  });

  testWidgets('muestra snackbar si falla el registrarTomaUseCase', (
    tester,
  ) async {
    when(() => mockSession.idUsuario).thenReturn(1);

    when(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    ).thenThrow(Exception('falló el caso de uso'));

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': true,
      'fase2_continuacion_activa': false,
      'dosis_pendientes': 20,
    };
    controller.dosisHoyMock = [];
    controller.medicamentoIdMock = 7;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TestHost(
              onPressed: () {
                controller.registrarTomaDesdeSesion(context: context);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al registrar la toma'), findsOneWidget);
  });

  testWidgets('muestra snackbar si falla obtenerTratamientoEnCurso', (
    tester,
  ) async {
    when(() => mockSession.idUsuario).thenReturn(1);
    controller.lanzarErrorEnTratamiento = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.registrarTomaDesdeSesion(context: context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al registrar la toma'), findsOneWidget);

    verifyNever(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    );
  });

  testWidgets('muestra snackbar si falla obtenerMedicamentoId', (tester) async {
    when(() => mockSession.idUsuario).thenReturn(1);
    controller.lanzarErrorEnMedicamento = true;

    controller.tratamientoMock = {
      'id': 100,
      'fase1_intensiva_activa': true,
      'fase2_continuacion_activa': false,
      'dosis_pendientes': 20,
    };
    controller.dosisHoyMock = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TestHost(
                onPressed: () {
                  controller.registrarTomaDesdeSesion(context: context);
                },
              ),
        ),
      ),
    );

    await tester.tap(find.text('tomar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Error al registrar la toma'), findsOneWidget);

    verifyNever(
      () => mockUseCase(
        idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
        idMedicamento: any(named: 'idMedicamento'),
        fechaHoraToma: any(named: 'fechaHoraToma'),
        estado: any(named: 'estado'),
      ),
    );
  });

  testWidgets(
    'registra toma en fase de continuacion y navega a exito sin activar fase 2 ni completar tratamiento',
    (tester) async {
      when(() => mockSession.idUsuario).thenReturn(1);

      when(
        () => mockUseCase(
          idTratamientoPaciente: any(named: 'idTratamientoPaciente'),
          idMedicamento: any(named: 'idMedicamento'),
          fechaHoraToma: any(named: 'fechaHoraToma'),
          estado: any(named: 'estado'),
        ),
      ).thenAnswer((_) async {});

      controller.tratamientoMock = {
        'id': 200,
        'fase1_intensiva_activa': false,
        'fase2_continuacion_activa': true,
        'dosis_pendientes': 10,
      };
      controller.dosisHoyMock = [];
      controller.medicamentoIdMock = 9;
      controller.totalDosisTomadasMock = 12;

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.exitoToma:
                (_) => const Scaffold(body: Text('Pantalla éxito toma')),
          },
          home: Builder(
            builder:
                (context) => TestHost(
                  onPressed: () {
                    controller.registrarTomaDesdeSesion(context: context);
                  },
                ),
          ),
        ),
      );

      await tester.tap(find.text('tomar'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(
        () => mockUseCase(
          idTratamientoPaciente: 200,
          idMedicamento: 9,
          fechaHoraToma: any(named: 'fechaHoraToma'),
          estado: 'Tomada',
        ),
      ).called(1);

      expect(controller.actualizarPendientesLlamado, true);
      expect(controller.activarFase2Llamado, false);
      expect(controller.completarTratamientoLlamado, false);
      expect(find.text('Pantalla éxito toma'), findsOneWidget);
    },
  );
}
