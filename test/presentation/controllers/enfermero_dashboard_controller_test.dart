import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/entities/enfermero_resumen_paciente.dart';
import 'package:tb_app/domain/entities/sintoma.dart';

import 'package:tb_app/domain/usecases/obtener_dashboard_enfermero_usecase.dart';
import 'package:tb_app/domain/usecases/validar_toma_paciente_enfermero_usecase.dart';
import 'package:tb_app/domain/usecases/registrar_seguimiento_clinico_usecase.dart';
import 'package:tb_app/domain/usecases/obtener_catalogo_sintomas_usecase.dart';

import 'package:tb_app/presentation/controllers/enfermero_dashboard_controller.dart';

class MockDashboardUseCase extends Mock
    implements ObtenerDashboardEnfermeroUseCase {}

class MockValidarTomaUseCase extends Mock
    implements ValidarTomaPacienteEnfermeroUseCase {}

class MockSeguimientoUseCase extends Mock
    implements RegistrarSeguimientoClinicoUseCase {}

class MockSintomasUseCase extends Mock
    implements ObtenerCatalogoSintomasUseCase {}

void main() {
  late EnfermeroDashboardController controller;

  late MockDashboardUseCase mockDashboard;
  late MockValidarTomaUseCase mockValidar;
  late MockSeguimientoUseCase mockSeguimiento;
  late MockSintomasUseCase mockSintomas;

  setUp(() {
    mockDashboard = MockDashboardUseCase();
    mockValidar = MockValidarTomaUseCase();
    mockSeguimiento = MockSeguimientoUseCase();
    mockSintomas = MockSintomasUseCase();

    controller = EnfermeroDashboardController(
      useCase: mockDashboard,
      validarTomaUseCase: mockValidar,
      registrarSeguimientoUseCase: mockSeguimiento,
      obtenerCatalogoSintomasUseCase: mockSintomas,
    );
  });

  group('EnfermeroDashboardController', () {
    test('estado inicial correcto', () {
      expect(controller.cargando, false);
      expect(controller.guardando, false);
      expect(controller.pacientes, isEmpty);
      expect(controller.error, null);
    });

    test('cargarPacientesAsignados carga datos correctamente', () async {
      final pacientes = [
        const EnfermeroResumenPaciente(
          idPaciente: 1,
          idTratamiento: 10,
          nombrePaciente: 'Juan',
          correoPaciente: 'juan@test.com',
          faseActual: 'Intensiva',
          estadoTratamiento: 'En curso',
          dosisTomadas: 10,
          dosisTotales: 60,
          dosisHoyTomada: true,
          reportoSintomasHoy: false,
          prioridadClinica: 2,
        ),
      ];

      when(() => mockDashboard(1)).thenAnswer((_) async => pacientes);

      await controller.cargarPacientesAsignados(1);

      expect(controller.cargando, false);
      expect(controller.pacientes.length, 1);
      expect(controller.error, null);

      verify(() => mockDashboard(1)).called(1);
    });

    test('cargarPacientesAsignados maneja error', () async {
      when(() => mockDashboard(1)).thenThrow(Exception('fallo'));

      await controller.cargarPacientesAsignados(1);

      expect(controller.cargando, false);
      expect(controller.pacientes, isEmpty);
      expect(controller.error, isNotNull);
    });

    test('cargando es true durante la ejecución', () async {
      when(() => mockDashboard(1)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final future = controller.cargarPacientesAsignados(1);

      expect(controller.cargando, true);

      await future;

      expect(controller.cargando, false);
    });

    test('cargarCatalogoSintomas carga correctamente', () async {
      final sintomas = [const Sintoma(id: 1, nombre: 'Fiebre')];

      when(() => mockSintomas()).thenAnswer((_) async => sintomas);

      await controller.cargarCatalogoSintomas();

      expect(controller.sintomasCatalogo.length, 1);
    });

    test('validarTomaPaciente recarga pacientes', () async {
      when(
        () => mockValidar(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          estado: 'Tomada',
        ),
      ).thenAnswer((_) async {});

      when(() => mockDashboard(1)).thenAnswer((_) async => []);

      await controller.validarTomaPaciente(
        idEnfermero: 1,
        idPaciente: 1,
        idTratamientoPaciente: 10,
        estado: 'Tomada',
      );

      verify(
        () => mockValidar(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          estado: 'Tomada',
        ),
      ).called(1);

      verify(() => mockDashboard(1)).called(1);
    });

    test('registrarSeguimientoClinico recarga pacientes', () async {
      when(
        () => mockSeguimiento(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 1,
          idsSintomas: [1],
        ),
      ).thenAnswer((_) async {});

      when(() => mockDashboard(1)).thenAnswer((_) async => []);

      await controller.registrarSeguimientoClinico(
        idEnfermero: 1,
        idPaciente: 1,
        idTratamientoPaciente: 10,
        dosisOmitidas: 1,
        idsSintomas: [1],
      );

      verify(
        () => mockSeguimiento(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 1,
          idsSintomas: [1],
        ),
      ).called(1);

      verify(() => mockDashboard(1)).called(1);
    });
  });
}
