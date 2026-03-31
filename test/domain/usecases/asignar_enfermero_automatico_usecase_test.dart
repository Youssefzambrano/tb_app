import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/asignar_enfermero_automatico_usecase.dart';
import 'package:tb_app/domain/repositories/asignacion_enfermero_repository.dart';
import 'package:tb_app/domain/entities/asignacion_enfermero_resultado.dart';

class MockAsignacionEnfermeroRepository extends Mock
    implements AsignacionEnfermeroRepository {}

class MockAsignacionEnfermeroResultado extends Mock
    implements AsignacionEnfermeroResultado {}

void main() {
  late AsignarEnfermeroAutomaticoUseCase usecase;
  late MockAsignacionEnfermeroRepository mockRepository;
  late MockAsignacionEnfermeroResultado mockResultado;

  setUp(() {
    mockRepository = MockAsignacionEnfermeroRepository();
    mockResultado = MockAsignacionEnfermeroResultado();
    usecase = AsignarEnfermeroAutomaticoUseCase(mockRepository);
  });

  group('AsignarEnfermeroAutomaticoUseCase', () {
    const tIdPaciente = 1;

    test(
      'debe llamar al repository.asignarEnfermeroBalanceado con el id correcto',
      () async {
        when(
          () => mockRepository.asignarEnfermeroBalanceado(
            idPaciente: tIdPaciente,
          ),
        ).thenAnswer((_) async => mockResultado);

        await usecase(idPaciente: tIdPaciente);

        verify(
          () => mockRepository.asignarEnfermeroBalanceado(
            idPaciente: tIdPaciente,
          ),
        ).called(1);
      },
    );

    test(
      'debe retornar el resultado cuando el repository responde correctamente',
      () async {
        when(
          () => mockRepository.asignarEnfermeroBalanceado(
            idPaciente: tIdPaciente,
          ),
        ).thenAnswer((_) async => mockResultado);

        final result = await usecase(idPaciente: tIdPaciente);

        expect(result, same(mockResultado));
      },
    );

    test('debe retornar null cuando el repository retorna null', () async {
      when(
        () =>
            mockRepository.asignarEnfermeroBalanceado(idPaciente: tIdPaciente),
      ).thenAnswer((_) async => null);

      final result = await usecase(idPaciente: tIdPaciente);

      expect(result, isNull);
    });
  });
}
