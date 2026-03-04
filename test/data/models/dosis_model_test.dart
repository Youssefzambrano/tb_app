import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/dosis_model.dart';
import 'package:tb_app/domain/entities/dosis.dart';

void main() {
  final tFecha = DateTime(2023, 8, 15, 8, 30); // 15 de agosto, 8:30 AM

  final tDosisModel = DosisModel(
    id: 1,
    idTratamientoPaciente: 10,
    idMedicamento: 5,
    fechaHoraToma: tFecha,
    estado: 'Tomada',
  );

  group('DosisModel', () {
    test('debe ser una subclase de la entidad Dosis', () {
      expect(tDosisModel, isA<Dosis>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido cuando el Map tiene el formato de base de datos',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'id_tratamiento_paciente': 10,
            'id_medicamento': 5,
            'fecha_hora_toma': '2023-08-15T08:30:00.000',
            'estado': 'Tomada',
          };

          // Act
          final result = DosisModel.fromMap(map);

          // Assert
          expect(result.id, tDosisModel.id);
          expect(result.fechaHoraToma, tDosisModel.fechaHoraToma);
          expect(
            result.idTratamientoPaciente,
            tDosisModel.idTratamientoPaciente,
          );
        },
      );
    });

    group('toMap', () {
      test('debe retornar un Map con las llaves correctas en snake_case', () {
        // Act
        final result = tDosisModel.toMap();

        // Assert
        final expectedMap = {
          'id': 1,
          'id_tratamiento_paciente': 10,
          'id_medicamento': 5,
          'fecha_hora_toma': '2023-08-15T08:30:00.000',
          'estado': 'Tomada',
        };
        expect(result, expectedMap);
      });

      test('no debe incluir la llave "id" en el Map si el id es nulo', () {
        // Arrange
        final tDosisSinId = DosisModel(
          id: null,
          idTratamientoPaciente: 10,
          idMedicamento: 5,
          fechaHoraToma: tFecha,
          estado: 'Pendiente',
        );

        // Act
        final result = tDosisSinId.toMap();

        // Assert
        expect(result.containsKey('id'), false);
        expect(result['estado'], 'Pendiente');
      });
    });
  });
}
