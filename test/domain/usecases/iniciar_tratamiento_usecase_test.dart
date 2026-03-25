import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/iniciar_tratamiento_usecase.dart';
import 'package:tb_app/domain/repositories/tratamiento_repository.dart';
import 'package:tb_app/domain/entities/tratamiento_paciente.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f1.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f2.dart';
import 'package:tb_app/domain/entities/seguimiento_paciente.dart';

class MockTratamientoRepository extends Mock implements TratamientoRepository {}

class FakeTratamientoPaciente extends Fake implements TratamientoPaciente {}

class FakeMedicacionPacienteF1 extends Fake implements MedicacionPacienteF1 {}

class FakeMedicacionPacienteF2 extends Fake implements MedicacionPacienteF2 {}

class FakeSeguimientoPaciente extends Fake implements SeguimientoPaciente {}

void main() {
  late IniciarTratamientoUseCase usecase;
  late MockTratamientoRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTratamientoPaciente());
    registerFallbackValue(FakeMedicacionPacienteF1());
    registerFallbackValue(FakeMedicacionPacienteF2());
    registerFallbackValue(FakeSeguimientoPaciente());
  });

  setUp(() {
    mockRepository = MockTratamientoRepository();
    usecase = IniciarTratamientoUseCase(mockRepository);
  });

  group('IniciarTratamientoUseCase', () {
    test(
      'debe llamar al repository para iniciar tratamiento completo',
      () async {
        when(
          () => mockRepository.iniciarTratamientoCompleto(
            tratamiento: any(named: 'tratamiento'),
            medicacionF1: any(named: 'medicacionF1'),
            medicacionF2: any(named: 'medicacionF2'),
            seguimiento: any(named: 'seguimiento'),
          ),
        ).thenAnswer((_) async {});

        await usecase(idPaciente: 1, pesoPaciente: 70);

        verify(
          () => mockRepository.iniciarTratamientoCompleto(
            tratamiento: any(named: 'tratamiento'),
            medicacionF1: any(named: 'medicacionF1'),
            medicacionF2: any(named: 'medicacionF2'),
            seguimiento: any(named: 'seguimiento'),
          ),
        ).called(1);
      },
    );

    test('debe construir el tratamiento con valores correctos', () async {
      late TratamientoPaciente tratamientoCapturado;

      when(
        () => mockRepository.iniciarTratamientoCompleto(
          tratamiento: captureAny(named: 'tratamiento'),
          medicacionF1: any(named: 'medicacionF1'),
          medicacionF2: any(named: 'medicacionF2'),
          seguimiento: any(named: 'seguimiento'),
        ),
      ).thenAnswer((invocation) async {
        tratamientoCapturado =
            invocation.namedArguments[#tratamiento] as TratamientoPaciente;
      });

      await usecase(idPaciente: 10, pesoPaciente: 65);

      expect(tratamientoCapturado.idPaciente, 10);
      expect(tratamientoCapturado.totalDosis, 168);
      expect(tratamientoCapturado.dosisPendientes, 168);
      expect(tratamientoCapturado.estado, 'En curso');
      expect(tratamientoCapturado.fase1IntensivaActiva, true);
      expect(tratamientoCapturado.fase2ContinuacionActiva, false);
    });

    test('debe construir la medicacion F1 correctamente', () async {
      late MedicacionPacienteF1 medicacionF1Capturada;

      when(
        () => mockRepository.iniciarTratamientoCompleto(
          tratamiento: any(named: 'tratamiento'),
          medicacionF1: captureAny(named: 'medicacionF1'),
          medicacionF2: any(named: 'medicacionF2'),
          seguimiento: any(named: 'seguimiento'),
        ),
      ).thenAnswer((invocation) async {
        medicacionF1Capturada =
            invocation.namedArguments[#medicacionF1] as MedicacionPacienteF1;
      });

      await usecase(idPaciente: 5, pesoPaciente: 70);

      expect(medicacionF1Capturada.idMedicamento, 1);
      expect(medicacionF1Capturada.duracion, 56);
      expect(medicacionF1Capturada.frecuencia, 1);
    });

    test('debe construir la medicacion F2 correctamente', () async {
      late MedicacionPacienteF2 medicacionF2Capturada;

      when(
        () => mockRepository.iniciarTratamientoCompleto(
          tratamiento: any(named: 'tratamiento'),
          medicacionF1: any(named: 'medicacionF1'),
          medicacionF2: captureAny(named: 'medicacionF2'),
          seguimiento: any(named: 'seguimiento'),
        ),
      ).thenAnswer((invocation) async {
        medicacionF2Capturada =
            invocation.namedArguments[#medicacionF2] as MedicacionPacienteF2;
      });

      await usecase(idPaciente: 5, pesoPaciente: 70);

      expect(medicacionF2Capturada.idMedicamento, 2);
      expect(medicacionF2Capturada.duracion, 112);
      expect(medicacionF2Capturada.frecuencia, 1);
    });

    test('debe construir el seguimiento inicial correctamente', () async {
      late SeguimientoPaciente seguimientoCapturado;

      when(
        () => mockRepository.iniciarTratamientoCompleto(
          tratamiento: any(named: 'tratamiento'),
          medicacionF1: any(named: 'medicacionF1'),
          medicacionF2: any(named: 'medicacionF2'),
          seguimiento: captureAny(named: 'seguimiento'),
        ),
      ).thenAnswer((invocation) async {
        seguimientoCapturado =
            invocation.namedArguments[#seguimiento] as SeguimientoPaciente;
      });

      await usecase(idPaciente: 8, pesoPaciente: 70);

      expect(seguimientoCapturado.idPaciente, 8);
      expect(seguimientoCapturado.dosisOmitidas, 0);
    });
  });
}
