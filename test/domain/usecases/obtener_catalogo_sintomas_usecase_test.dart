import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tb_app/domain/entities/sintoma.dart';
import 'package:tb_app/domain/repositories/enfermero_dashboard_repository.dart';
import 'package:tb_app/domain/usecases/obtener_catalogo_sintomas_usecase.dart';

class MockEnfermeroDashboardRepository extends Mock
    implements EnfermeroDashboardRepository {}

void main() {
  late ObtenerCatalogoSintomasUseCase useCase;
  late MockEnfermeroDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockEnfermeroDashboardRepository();
    useCase = ObtenerCatalogoSintomasUseCase(mockRepository);
  });

  group('ObtenerCatalogoSintomasUseCase', () {
    test('debe retornar lista de sintomas correctamente', () async {
      final sintomas = [
        const Sintoma(id: 1, nombre: 'Fiebre'),
        const Sintoma(id: 2, nombre: 'Tos'),
        const Sintoma(id: 3, nombre: 'Sudoración nocturna'),
      ];

      when(
        () => mockRepository.obtenerCatalogoSintomas(),
      ).thenAnswer((_) async => sintomas);

      final result = await useCase();

      expect(result.length, 3);
      expect(result[0].nombre, 'Fiebre');
      expect(result[1].nombre, 'Tos');
      expect(result[2].nombre, 'Sudoración nocturna');

      verify(() => mockRepository.obtenerCatalogoSintomas()).called(1);
    });

    test('debe retornar lista vacia si no hay sintomas', () async {
      when(
        () => mockRepository.obtenerCatalogoSintomas(),
      ).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);

      verify(() => mockRepository.obtenerCatalogoSintomas()).called(1);
    });

    test('debe propagar excepciones del repositorio', () async {
      when(
        () => mockRepository.obtenerCatalogoSintomas(),
      ).thenThrow(Exception('error al obtener sintomas'));

      expect(() => useCase(), throwsA(isA<Exception>()));

      verify(() => mockRepository.obtenerCatalogoSintomas()).called(1);
    });
  });
}
