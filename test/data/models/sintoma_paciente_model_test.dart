import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/sintoma_paciente_model.dart';
import 'package:tb_app/domain/entities/sintoma_paciente.dart';

void main() {
  final tFecha = DateTime(2024, 2, 10, 15, 30); // 10 de Feb, 3:30 PM

  final tSintomaModel = SintomaPacienteModel(
    id: 1,
    idSeguimiento: 50,
    idSintoma: 5,
    fechaRegistro: tFecha,
  );
  group('SintomaPacienteModel', () {
    test('debe ser una subclase de la entidad SintomaPaciente', () {
      expect(tSintomaModel, isA<SintomaPaciente>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido cuando el Map tiene el formato correcto',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'id_seguimiento': 50,
            'id_sintoma': 5,
            'fecha_registro': '2024-02-10T15:30:00.000',
          };

          // Act
          final result = SintomaPacienteModel.fromMap(map);

          // Assert
          expect(result.id, tSintomaModel.id);
          expect(result.idSeguimiento, tSintomaModel.idSeguimiento);
          expect(result.idSintoma, tSintomaModel.idSintoma);
          expect(result.fechaRegistro, tFecha);
        },
      );
    });

    group('toMap', () {
      test('debe retornar un Map conteniendo los datos en snake_case', () {
        // Act
        final result = tSintomaModel.toMap();

        // Assert
        final expectedMap = {
          'id': 1,
          'id_seguimiento': 50,
          'id_sintoma': 5,
          'fecha_registro': '2024-02-10T15:30:00.000',
        };
        expect(result, expectedMap);
      });
    });
  });
}
