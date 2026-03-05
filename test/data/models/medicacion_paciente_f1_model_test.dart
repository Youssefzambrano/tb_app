import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/medicacion_paciente_f1_model.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f1.dart';

void main() {
  const tMedicacionModel = MedicacionPacienteF1Model(
    id: 1,
    idTratamientoPaciente: 10,
    idMedicamento: 5,
    dosisDiaria: 3.0,
    frecuencia: 1,
    duracion: 56,
  );

  group('MedicacionPacienteF1Model', () {
    test('debe ser una subclase de la entidad MedicacionPacienteF1', () {
      expect(tMedicacionModel, isA<MedicacionPacienteF1>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido convirtiendo int a double en la dosis',
        () {
          final Map<String, dynamic> map = {
            'id': 1,
            'id_tratamiento_paciente': 10,
            'id_medicamento': 5,
            'dosis_diaria': 3, // Viene como int desde el JSON
            'frecuencia': 1,
            'duracion': 56,
          };

          final result = MedicacionPacienteF1Model.fromMap(map);

          expect(result, tMedicacionModel);
          expect(result.dosisDiaria, 3.0);
        },
      );
    });

    group('toMap', () {
      test('debe retornar un Map con los datos correctos', () {
        final result = tMedicacionModel.toMap();
        final expectedMap = {
          'id': 1,
          'id_tratamiento_paciente': 10,
          'id_medicamento': 5,
          'dosis_diaria': 3.0,
          'frecuencia': 1,
          'duracion': 56,
        };
        expect(result, expectedMap);
      });

      test('debe omitir el ID en el mapa si es nulo', () {
        const modelSinId = MedicacionPacienteF1Model(
          idTratamientoPaciente: 10,
          idMedicamento: 5,
          dosisDiaria: 3.0,
          frecuencia: 1,
        );

        final result = modelSinId.toMap();
        expect(result.containsKey('id'), false);
      });
    });
  });
}
