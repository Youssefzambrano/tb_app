import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/repositories/enfermero_dashboard_repository.dart';
import 'package:tb_app/domain/usecases/registrar_seguimiento_clinico_usecase.dart';

class MockEnfermeroDashboardRepository extends Mock
    implements EnfermeroDashboardRepository {}

void main() {
  late RegistrarSeguimientoClinicoUseCase useCase;
  late MockEnfermeroDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockEnfermeroDashboardRepository();
    useCase = RegistrarSeguimientoClinicoUseCase(mockRepository);
  });

  group('RegistrarSeguimientoClinicoUseCase', () {
    test('debe registrar seguimiento sin sintomas correctamente', () async {
      when(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 0,
          idsSintomas: [],
        ),
      ).thenAnswer((_) async {});

      await useCase(
        idPaciente: 1,
        idTratamientoPaciente: 10,
        dosisOmitidas: 0,
        idsSintomas: [],
      );

      verify(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 0,
          idsSintomas: [],
        ),
      ).called(1);
    });

    test('debe registrar seguimiento con sintomas correctamente', () async {
      when(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 2,
          idTratamientoPaciente: 20,
          dosisOmitidas: 2,
          idsSintomas: [1, 3],
        ),
      ).thenAnswer((_) async {});

      await useCase(
        idPaciente: 2,
        idTratamientoPaciente: 20,
        dosisOmitidas: 2,
        idsSintomas: [1, 3],
      );

      verify(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 2,
          idTratamientoPaciente: 20,
          dosisOmitidas: 2,
          idsSintomas: [1, 3],
        ),
      ).called(1);
    });

    test('debe propagar excepciones del repositorio', () async {
      when(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 1,
          idsSintomas: [2],
        ),
      ).thenThrow(Exception('error al registrar seguimiento'));

      expect(
        () => useCase(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 1,
          idsSintomas: [2],
        ),
        throwsA(isA<Exception>()),
      );

      verify(
        () => mockRepository.registrarSeguimientoClinico(
          idPaciente: 1,
          idTratamientoPaciente: 10,
          dosisOmitidas: 1,
          idsSintomas: [2],
        ),
      ).called(1);
    });
  });
}
