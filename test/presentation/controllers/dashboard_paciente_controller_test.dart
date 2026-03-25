import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/obtener_dashboard_paciente_usecase.dart';
import 'package:tb_app/presentation/controllers/dashboard_peciente_controller.dart';
import 'package:tb_app/presentation/viewmodels/dashboard_resumen_paciente.dart';

class MockObtenerDashboardPacienteUseCase extends Mock
    implements ObtenerDashboardPacienteUseCase {}

void main() {
  late DashboardPacienteController controller;
  late MockObtenerDashboardPacienteUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockObtenerDashboardPacienteUseCase();
    controller = DashboardPacienteController(useCase: mockUseCase);
  });

  group('DashboardPacienteController', () {
    test('cargarResumen carga correctamente los datos', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 20,
        dosisTotales: 60,
        porcentaje: 33,
        faseActual: 'Intensiva',
        ultimaDosis: DateTime.now(),
        dosisDeHoyTomada: true,
        medicamentoActual: 'Rifampicina',
        diasCompletados: 20,
        diasRestantes: 40,
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
      expect(controller.error, contains('Error al cargar el resumen'));
    });

    test('cargando es true durante la ejecución', () async {
      when(() => mockUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return DashboardPacienteResumen(
          dosisTomadas: 10,
          dosisTotales: 60,
          porcentaje: 20,
          faseActual: 'Intensiva',
          ultimaDosis: null,
          dosisDeHoyTomada: false,
          medicamentoActual: '',
          diasCompletados: 10,
          diasRestantes: 50,
          fechaInicio: null,
          fechaFin: null,
        );
      });

      final future = controller.cargarResumen(1);

      expect(controller.cargando, true);

      await future;

      expect(controller.cargando, false);
    });

    test('limpiar resetea el estado', () async {
      final resumen = DashboardPacienteResumen(
        dosisTomadas: 20,
        dosisTotales: 60,
        porcentaje: 33,
        faseActual: 'Intensiva',
        ultimaDosis: DateTime.now(),
        dosisDeHoyTomada: true,
        medicamentoActual: 'Rifampicina',
        diasCompletados: 20,
        diasRestantes: 40,
        fechaInicio: DateTime(2024, 1, 1),
        fechaFin: DateTime(2024, 3, 1),
      );

      when(() => mockUseCase(any())).thenAnswer((_) async => resumen);

      await controller.cargarResumen(1);

      controller.limpiar();

      expect(controller.resumen, isNull);
      expect(controller.error, isNull);
    });
  });
}
