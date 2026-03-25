import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/entities/dosis.dart';
import 'package:tb_app/domain/repositories/dosis_repository.dart';
import 'package:tb_app/domain/usecases/registrar_toma_usecase.dart';

class MockDosisRepository extends Mock implements DosisRepository {}

class FakeDosis extends Fake implements Dosis {}

void main() {
  late RegistrarTomaUseCase usecase;
  late MockDosisRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeDosis());
  });

  setUp(() {
    mockRepository = MockDosisRepository();
    usecase = RegistrarTomaUseCase(mockRepository);
  });

  group('RegistrarTomaUseCase', () {
    test('debe llamar al repository para registrar la dosis', () async {
      when(() => mockRepository.registrarDosis(any())).thenAnswer((_) async {});

      await usecase(
        idTratamientoPaciente: 10,
        idMedicamento: 2,
        fechaHoraToma: DateTime(2024, 1, 1, 8, 0),
        estado: 'tomada',
      );

      verify(() => mockRepository.registrarDosis(any())).called(1);
    });

    test('debe construir correctamente la entidad Dosis', () async {
      late Dosis dosisCapturada;

      when(() => mockRepository.registrarDosis(captureAny())).thenAnswer((
        invocation,
      ) async {
        dosisCapturada = invocation.positionalArguments[0] as Dosis;
      });

      final fecha = DateTime(2024, 1, 1, 8, 0);

      await usecase(
        idTratamientoPaciente: 10,
        idMedicamento: 2,
        fechaHoraToma: fecha,
        estado: 'tomada',
      );

      expect(dosisCapturada.id, isNull);
      expect(dosisCapturada.idTratamientoPaciente, 10);
      expect(dosisCapturada.idMedicamento, 2);
      expect(dosisCapturada.fechaHoraToma, fecha);
      expect(dosisCapturada.estado, 'tomada');
    });
  });
}
