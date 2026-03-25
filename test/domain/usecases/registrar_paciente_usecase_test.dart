import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/entities/paciente.dart';
import 'package:tb_app/domain/repositories/paciente_repository.dart';
import 'package:tb_app/domain/usecases/registrar_paciente_usecase.dart';

class MockPacienteRepository extends Mock implements PacienteRepository {}

class FakePaciente extends Fake implements Paciente {}

void main() {
  late RegistrarPacienteUseCase usecase;
  late MockPacienteRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakePaciente());
  });

  setUp(() {
    mockRepository = MockPacienteRepository();
    usecase = RegistrarPacienteUseCase(mockRepository);
  });

  group('RegistrarPacienteUseCase', () {
    test('debe llamar al repository para registrar paciente', () async {
      when(
        () => mockRepository.registrarPaciente(any()),
      ).thenAnswer((_) async {});

      await usecase(
        idUsuario: 1,
        nombreContacto: 'Maria',
        telefonoContacto: '3001234567',
      );

      verify(() => mockRepository.registrarPaciente(any())).called(1);
    });

    test(
      'debe construir correctamente el paciente con valores por defecto',
      () async {
        late Paciente pacienteCapturado;

        when(() => mockRepository.registrarPaciente(captureAny())).thenAnswer((
          invocation,
        ) async {
          pacienteCapturado = invocation.positionalArguments[0] as Paciente;
        });

        await usecase(
          idUsuario: 1,
          nombreContacto: 'Maria',
          telefonoContacto: '3001234567',
        );

        expect(pacienteCapturado.id, 1);
        expect(pacienteCapturado.fechaDiagnostico, isNull);
        expect(pacienteCapturado.tipoTuberculosis, 'Sensible');
        expect(pacienteCapturado.estadoTratamiento, 'Activo');
        expect(pacienteCapturado.nombreContactoEmergencia, 'Maria');
        expect(pacienteCapturado.telefonoContactoEmergencia, '3001234567');
      },
    );
  });
}
