import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/enfermero_model.dart';
import 'package:tb_app/domain/entities/enfermero.dart';

void main() {
  // Objeto de prueba con un ID ficticio
  const tEnfermeroModel = EnfermeroModel(id: 1);

  group('EnfermeroModel', () {
    test('debe ser una subclase de la entidad Enfermero', () {
      // Verifica que el modelo herede de la entidad (Domain)
      expect(tEnfermeroModel, isA<Enfermero>());
    });

    group('fromMap', () {
      test('debe retornar un modelo válido cuando el Map contiene el ID', () {
        // Arrange
        final Map<String, dynamic> map = {'id': 1};

        // Act
        final result = EnfermeroModel.fromMap(map);

        // Assert
        expect(result.id, tEnfermeroModel.id);
      });
    });

    group('toMap', () {
      test('debe retornar un Map conteniendo los datos del modelo', () {
        // Act
        final result = tEnfermeroModel.toMap();

        // Assert
        final expectedMap = {'id': 1};
        expect(result, expectedMap);
      });
    });
  });
}
