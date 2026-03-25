import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/obtener_dashboard_paciente_usecase.dart';
import 'package:tb_app/presentation/controllers/resumen_fase_controller.dart';
import 'package:tb_app/presentation/viewmodels/dashboard_resumen_paciente.dart';

class MockObtenerDashboardPacienteUseCase extends Mock
    implements ObtenerDashboardPacienteUseCase {}

void main() {
  late ResumenFaseController controller;
  late MockObtenerDashboardPacienteUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockObtenerDashboardPacienteUseCase();
    controller = ResumenFaseController(useCase: mockUseCase);
  });

  group('ResumenFaseController', () {
    test('cargarResumen carga correctamente los datos', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 10,
        dosisTotales: 60,
        porcentaje: 20,
        faseActual: 'Intensiva',
        ultimaDosis: DateTime.now(),
        dosisDeHoyTomada: true,
        medicamentoActual: 'Rifampicina',
        diasCompletados: 10,
        diasRestantes: 46,
        fechaInicio: DateTime(2024, 1, 1),
        fechaFin: DateTime(2024, 3, 1),
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.cargando, false);
      expect(controller.error, isNull);
      expect(controller.resumen, resumen);
    });

    test('cargarResumen maneja error correctamente', () async {
      when(() => mockUseCase(any())).thenThrow(Exception('fallo'));

      await controller.cargarResumen(1);

      expect(controller.cargando, false);
      expect(controller.resumen, isNull);
      expect(controller.error, contains('Error al obtener resumen'));
    });

    test('diasCompletados retorna valor correcto', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 10,
        dosisTotales: 60,
        porcentaje: 20,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 15,
        diasRestantes: 40,
        fechaInicio: null,
        fechaFin: null,
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.diasCompletados, 15);
    });

    test('diasRestantes retorna valor correcto', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 10,
        dosisTotales: 60,
        porcentaje: 20,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 15,
        diasRestantes: 40,
        fechaInicio: null,
        fechaFin: null,
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.diasRestantes, 40);
    });

    test('fechaInicio retorna fecha formateada correctamente', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 60,
        dosisTotales: 60,
        porcentaje: 100,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 60,
        diasRestantes: 0,
        fechaInicio: DateTime(2024, 1, 5),
        fechaFin: null,
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.fechaInicio, '05/01/2024');
    });

    test(
      'fechaInicio retorna Pendiente en fase Continuación con menos de 57 dosis',
      () async {
        final resumen = DashboardPacienteResumen(
          dosisTomadas: 30,
          dosisTotales: 120,
          porcentaje: 25,
          faseActual: 'Continuación',
          ultimaDosis: null,
          dosisDeHoyTomada: false,
          medicamentoActual: '',
          diasCompletados: 30,
          diasRestantes: 90,
          fechaInicio: DateTime(2024, 1, 1),
          fechaFin: null,
        );

        when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

        await controller.cargarResumen(1);

        expect(controller.fechaInicio, 'Pendiente');
      },
    );

    test('fechaInicio retorna Pendiente si fechaInicio es null', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 60,
        dosisTotales: 120,
        porcentaje: 50,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 60,
        diasRestantes: 60,
        fechaInicio: null,
        fechaFin: null,
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.fechaInicio, 'Pendiente');
    });

    test('fechaFin retorna fecha formateada correctamente', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 60,
        dosisTotales: 60,
        porcentaje: 100,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 60,
        diasRestantes: 0,
        fechaInicio: null,
        fechaFin: DateTime(2024, 3, 10),
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.fechaFin, '10/03/2024');
    });

    test('fechaFin retorna Pendiente si fechaFin es null', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 60,
        dosisTotales: 60,
        porcentaje: 100,
        faseActual: 'Intensiva',
        ultimaDosis: null,
        dosisDeHoyTomada: false,
        medicamentoActual: '',
        diasCompletados: 60,
        diasRestantes: 0,
        fechaInicio: null,
        fechaFin: null,
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      expect(controller.fechaFin, 'Pendiente');
    });
  });
}
