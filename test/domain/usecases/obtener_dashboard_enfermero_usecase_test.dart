import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/entities/enfermero_resumen_paciente.dart';
import 'package:tb_app/domain/repositories/enfermero_dashboard_repository.dart';
import 'package:tb_app/domain/usecases/obtener_dashboard_enfermero_usecase.dart';

class MockEnfermeroDashboardRepository extends Mock
    implements EnfermeroDashboardRepository {}

void main() {
  late ObtenerDashboardEnfermeroUseCase useCase;
  late MockEnfermeroDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockEnfermeroDashboardRepository();
    useCase = ObtenerDashboardEnfermeroUseCase(mockRepository);
  });

  group('ObtenerDashboardEnfermeroUseCase', () {
    test(
      'debe retornar la lista vacia si el repositorio no devuelve pacientes',
      () async {
        when(
          () => mockRepository.obtenerResumenPacientesAsignados(1),
        ).thenAnswer((_) async => []);

        final result = await useCase(1);

        expect(result, isEmpty);
        verify(
          () => mockRepository.obtenerResumenPacientesAsignados(1),
        ).called(1);
      },
    );

    test('debe ordenar por prioridad clinica descendente', () async {
      final pacientes = [
        const EnfermeroResumenPaciente(
          idPaciente: 1,
          idTratamiento: 10,
          nombrePaciente: 'Paciente A',
          correoPaciente: 'a@test.com',
          faseActual: 'Intensiva',
          estadoTratamiento: 'En curso',
          dosisTomadas: 30,
          dosisTotales: 60,
          dosisHoyTomada: true,
          reportoSintomasHoy: false,
          prioridadClinica: 1,
        ),
        const EnfermeroResumenPaciente(
          idPaciente: 2,
          idTratamiento: 20,
          nombrePaciente: 'Paciente B',
          correoPaciente: 'b@test.com',
          faseActual: 'Continuación',
          estadoTratamiento: 'En curso',
          dosisTomadas: 20,
          dosisTotales: 60,
          dosisHoyTomada: false,
          reportoSintomasHoy: true,
          prioridadClinica: 3,
        ),
        const EnfermeroResumenPaciente(
          idPaciente: 3,
          idTratamiento: 30,
          nombrePaciente: 'Paciente C',
          correoPaciente: 'c@test.com',
          faseActual: 'Intensiva',
          estadoTratamiento: 'En curso',
          dosisTomadas: 25,
          dosisTotales: 60,
          dosisHoyTomada: true,
          reportoSintomasHoy: false,
          prioridadClinica: 2,
        ),
      ];

      when(
        () => mockRepository.obtenerResumenPacientesAsignados(7),
      ).thenAnswer((_) async => pacientes);

      final result = await useCase(7);

      expect(result.length, 3);
      expect(result[0].idPaciente, 2);
      expect(result[1].idPaciente, 3);
      expect(result[2].idPaciente, 1);

      verify(
        () => mockRepository.obtenerResumenPacientesAsignados(7),
      ).called(1);
    });

    test(
      'debe ordenar por adherencia ascendente cuando la prioridad clinica es igual',
      () async {
        final pacientes = [
          const EnfermeroResumenPaciente(
            idPaciente: 1,
            idTratamiento: 10,
            nombrePaciente: 'Paciente A',
            correoPaciente: 'a@test.com',
            faseActual: 'Intensiva',
            estadoTratamiento: 'En curso',
            dosisTomadas: 54,
            dosisTotales: 60,
            dosisHoyTomada: true,
            reportoSintomasHoy: false,
            prioridadClinica: 2,
          ),
          const EnfermeroResumenPaciente(
            idPaciente: 2,
            idTratamiento: 20,
            nombrePaciente: 'Paciente B',
            correoPaciente: 'b@test.com',
            faseActual: 'Continuación',
            estadoTratamiento: 'En curso',
            dosisTomadas: 12,
            dosisTotales: 60,
            dosisHoyTomada: false,
            reportoSintomasHoy: false,
            prioridadClinica: 2,
          ),
          const EnfermeroResumenPaciente(
            idPaciente: 3,
            idTratamiento: 30,
            nombrePaciente: 'Paciente C',
            correoPaciente: 'c@test.com',
            faseActual: 'Intensiva',
            estadoTratamiento: 'En curso',
            dosisTomadas: 30,
            dosisTotales: 60,
            dosisHoyTomada: true,
            reportoSintomasHoy: false,
            prioridadClinica: 2,
          ),
        ];

        when(
          () => mockRepository.obtenerResumenPacientesAsignados(5),
        ).thenAnswer((_) async => pacientes);

        final result = await useCase(5);

        expect(result.length, 3);

        // Adherencias:
        // Paciente 2 = 20%
        // Paciente 3 = 50%
        // Paciente 1 = 90%
        expect(result[0].idPaciente, 2);
        expect(result[1].idPaciente, 3);
        expect(result[2].idPaciente, 1);

        verify(
          () => mockRepository.obtenerResumenPacientesAsignados(5),
        ).called(1);
      },
    );

    test(
      'debe priorizar primero prioridad clinica y luego adherencia en caso de empate',
      () async {
        final pacientes = [
          const EnfermeroResumenPaciente(
            idPaciente: 1,
            idTratamiento: 10,
            nombrePaciente: 'Paciente A',
            correoPaciente: 'a@test.com',
            faseActual: 'Intensiva',
            estadoTratamiento: 'En curso',
            dosisTomadas: 50,
            dosisTotales: 60,
            dosisHoyTomada: true,
            reportoSintomasHoy: false,
            prioridadClinica: 2,
          ),
          const EnfermeroResumenPaciente(
            idPaciente: 2,
            idTratamiento: 20,
            nombrePaciente: 'Paciente B',
            correoPaciente: 'b@test.com',
            faseActual: 'Continuación',
            estadoTratamiento: 'En curso',
            dosisTomadas: 10,
            dosisTotales: 60,
            dosisHoyTomada: false,
            reportoSintomasHoy: true,
            prioridadClinica: 3,
          ),
          const EnfermeroResumenPaciente(
            idPaciente: 3,
            idTratamiento: 30,
            nombrePaciente: 'Paciente C',
            correoPaciente: 'c@test.com',
            faseActual: 'Intensiva',
            estadoTratamiento: 'En curso',
            dosisTomadas: 20,
            dosisTotales: 60,
            dosisHoyTomada: false,
            reportoSintomasHoy: false,
            prioridadClinica: 3,
          ),
          const EnfermeroResumenPaciente(
            idPaciente: 4,
            idTratamiento: 40,
            nombrePaciente: 'Paciente D',
            correoPaciente: 'd@test.com',
            faseActual: 'Continuación',
            estadoTratamiento: 'En curso',
            dosisTomadas: 5,
            dosisTotales: 60,
            dosisHoyTomada: false,
            reportoSintomasHoy: false,
            prioridadClinica: 1,
          ),
        ];

        when(
          () => mockRepository.obtenerResumenPacientesAsignados(9),
        ).thenAnswer((_) async => pacientes);

        final result = await useCase(9);

        expect(result.length, 4);

        // Prioridad 3 primero, y dentro de esa prioridad:
        // Paciente 2 = 16.66%
        // Paciente 3 = 33.33%
        expect(result[0].idPaciente, 2);
        expect(result[1].idPaciente, 3);

        // Luego prioridad 2
        expect(result[2].idPaciente, 1);

        // Luego prioridad 1
        expect(result[3].idPaciente, 4);

        verify(
          () => mockRepository.obtenerResumenPacientesAsignados(9),
        ).called(1);
      },
    );

    test('debe propagar la excepcion del repositorio', () async {
      when(
        () => mockRepository.obtenerResumenPacientesAsignados(3),
      ).thenThrow(Exception('fallo al obtener dashboard'));

      expect(() => useCase(3), throwsA(isA<Exception>()));

      verify(
        () => mockRepository.obtenerResumenPacientesAsignados(3),
      ).called(1);
    });
  });
}
