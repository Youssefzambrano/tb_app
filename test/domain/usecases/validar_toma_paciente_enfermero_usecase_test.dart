import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/repositories/enfermero_dashboard_repository.dart';
import 'package:tb_app/domain/usecases/validar_toma_paciente_enfermero_usecase.dart';

class MockEnfermeroDashboardRepository extends Mock
    implements EnfermeroDashboardRepository {}

void main() {
  late ValidarTomaPacienteEnfermeroUseCase useCase;
  late MockEnfermeroDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockEnfermeroDashboardRepository();
    useCase = ValidarTomaPacienteEnfermeroUseCase(mockRepository);
  });

  group('ValidarTomaPacienteEnfermeroUseCase', () {
    test('debe validar toma correctamente con estado TOMADA', () async {
      when(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          estado: 'Tomada',
        ),
      ).thenAnswer((_) async {});

      await useCase(idPaciente: 1, idTratamientoPaciente: 10, estado: 'Tomada');

      verify(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          estado: 'Tomada',
        ),
      ).called(1);
    });

    test('debe validar toma correctamente con estado OMITIDA', () async {
      when(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 2,
          idTratamientoPaciente: 20,
          estado: 'Omitida',
        ),
      ).thenAnswer((_) async {});

      await useCase(
        idPaciente: 2,
        idTratamientoPaciente: 20,
        estado: 'Omitida',
      );

      verify(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 2,
          idTratamientoPaciente: 20,
          estado: 'Omitida',
        ),
      ).called(1);
    });

    test('debe propagar excepciones del repositorio', () async {
      when(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 3,
          idTratamientoPaciente: 30,
          estado: 'Tomada',
        ),
      ).thenThrow(Exception('error al validar toma'));

      expect(
        () =>
            useCase(idPaciente: 3, idTratamientoPaciente: 30, estado: 'Tomada'),
        throwsA(isA<Exception>()),
      );

      verify(
        () => mockRepository.validarTomaPaciente(
          idPaciente: 3,
          idTratamientoPaciente: 30,
          estado: 'Tomada',
        ),
      ).called(1);
    });
  });
}
