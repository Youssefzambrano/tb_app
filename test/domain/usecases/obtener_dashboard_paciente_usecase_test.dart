import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/usecases/obtener_dashboard_paciente_usecase.dart';
import 'package:tb_app/domain/repositories/dosis_repository.dart';
import 'package:tb_app/domain/repositories/tratamiento_repository.dart';
import 'package:tb_app/domain/repositories/medicacion_repository.dart';
import 'package:tb_app/domain/entities/tratamiento_paciente.dart';
import 'package:tb_app/domain/entities/dosis.dart';

class MockDosisRepository extends Mock implements DosisRepository {}

class MockTratamientoRepository extends Mock implements TratamientoRepository {}

class MockMedicacionRepository extends Mock implements MedicacionRepository {}

class FakeTratamiento extends Fake implements TratamientoPaciente {}

class FakeDosis extends Fake implements Dosis {}

void main() {
  late ObtenerDashboardPacienteUseCase usecase;
  late MockDosisRepository mockDosisRepo;
  late MockTratamientoRepository mockTratamientoRepo;
  late MockMedicacionRepository mockMedicacionRepo;

  setUpAll(() {
    registerFallbackValue(FakeTratamiento());
    registerFallbackValue(FakeDosis());
  });

  setUp(() {
    mockDosisRepo = MockDosisRepository();
    mockTratamientoRepo = MockTratamientoRepository();
    mockMedicacionRepo = MockMedicacionRepository();

    usecase = ObtenerDashboardPacienteUseCase(
      dosisRepo: mockDosisRepo,
      tratamientoRepo: mockTratamientoRepo,
      medicacionRepo: mockMedicacionRepo,
    );
  });

  group('ObtenerDashboardPacienteUseCase', () {
    test(
      'debe construir correctamente el dashboard en fase intensiva',
      () async {
        final fechaInicio = DateTime.now().subtract(const Duration(days: 10));

        final tratamiento = TratamientoPaciente(
          id: 1,
          idPaciente: 1,
          nombre: 'Tratamiento TB',
          fechaInicio: fechaInicio,
          fechaInicioFase1: fechaInicio,
          fechaInicioFase2: null,
          duracionTotal: 60,
          totalDosis: 60,
          dosisPendientes: 50,
          estado: 'En curso',
          fase1IntensivaActiva: true,
          fase2ContinuacionActiva: false,
        );

        when(
          () => mockTratamientoRepo.obtenerTratamientoActivo(any()),
        ).thenAnswer((_) async => tratamiento);

        when(
          () => mockDosisRepo.contarDosisPorUsuario(any()),
        ).thenAnswer((_) async => 10);

        when(() => mockDosisRepo.obtenerUltimaDosis(any())).thenAnswer(
          (_) async => Dosis(
            id: 1,
            idTratamientoPaciente: 1,
            idMedicamento: 1,
            fechaHoraToma: DateTime.now(),
            estado: 'tomada',
          ),
        );

        when(
          () => mockDosisRepo.existeDosisHoy(any()),
        ).thenAnswer((_) async => true);

        when(
          () => mockMedicacionRepo.obtenerIdMedicamentoF1(any()),
        ).thenAnswer((_) async => 1);

        when(
          () => mockMedicacionRepo.obtenerNombreMedicamento(any()),
        ).thenAnswer((_) async => 'Rifampicina');

        final result = await usecase(1);

        expect(result.dosisTomadas, 10);
        expect(result.dosisTotales, 60);
        expect(result.porcentaje, closeTo(16.6, 1));
        expect(result.faseActual, 'Intensiva');
        expect(result.medicamentoActual, 'Rifampicina');
        expect(result.dosisDeHoyTomada, true);
        expect(result.fechaInicio, fechaInicio);
        expect(result.fechaFin, isNotNull);
        expect(result.diasCompletados, greaterThanOrEqualTo(0));
        expect(result.diasRestantes, greaterThanOrEqualTo(0));
      },
    );

    test(
      'debe construir correctamente el dashboard en fase continuacion',
      () async {
        final fechaInicio = DateTime.now().subtract(const Duration(days: 20));

        final tratamiento = TratamientoPaciente(
          id: 1,
          idPaciente: 1,
          nombre: 'Tratamiento TB',
          fechaInicio: fechaInicio,
          fechaInicioFase1: null,
          fechaInicioFase2: fechaInicio,
          duracionTotal: 120,
          totalDosis: 120,
          dosisPendientes: 90,
          estado: 'En curso',
          fase1IntensivaActiva: false,
          fase2ContinuacionActiva: true,
        );

        when(
          () => mockTratamientoRepo.obtenerTratamientoActivo(any()),
        ).thenAnswer((_) async => tratamiento);

        when(
          () => mockDosisRepo.contarDosisPorUsuario(any()),
        ).thenAnswer((_) async => 30);

        when(
          () => mockDosisRepo.obtenerUltimaDosis(any()),
        ).thenAnswer((_) async => null);

        when(
          () => mockDosisRepo.existeDosisHoy(any()),
        ).thenAnswer((_) async => false);

        when(
          () => mockMedicacionRepo.obtenerIdMedicamentoF2(any()),
        ).thenAnswer((_) async => 2);

        when(
          () => mockMedicacionRepo.obtenerNombreMedicamento(any()),
        ).thenAnswer((_) async => 'Isoniazida');

        final result = await usecase(1);

        expect(result.faseActual, 'Continuación');
        expect(result.medicamentoActual, 'Isoniazida');
        expect(result.dosisDeHoyTomada, false);
        expect(result.porcentaje, closeTo(25.0, 1));
        expect(result.fechaInicio, fechaInicio);
        expect(result.fechaFin, isNotNull);
        expect(result.diasCompletados, greaterThanOrEqualTo(0));
        expect(result.diasRestantes, greaterThanOrEqualTo(0));
      },
    );
  });
}
