import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/medicacion_paciente_f2_model.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f2.dart';

void main() {
  const tMedicacionF2Model = MedicacionPacienteF2Model(
    id: 2,
    idTratamientoPaciente: 10,
    idMedicamento: 8,
    dosisDiaria: 2.0,
    frecuencia: 3, // Ejemplo: 3 veces por semana en Fase 2
    duracion: 126,
  );

  group('MedicacionPacienteF2Model', () {
    test('debe ser una subclase de la entidad MedicacionPacienteF2', () {
      expect(tMedicacionF2Model, isA<MedicacionPacienteF2>());
    });

    group('fromMap', () {
      test('debe retornar un modelo válido desde el Map', () {
        final Map<String, dynamic> map = {
          'id': 2,
          'id_tratamiento_paciente': 10,
          'id_medicamento': 8,
          'dosis_diaria': 2.0,
          'frecuencia': 3,
          'duracion': 126,
        };

        final result = MedicacionPacienteF2Model.fromMap(map);

        expect(result, tMedicacionF2Model);
      });
    });

    group('toMap', () {
      test('debe retornar un Map con los datos correctos', () {
        final result = tMedicacionF2Model.toMap();
        final expectedMap = {
          'id': 2,
          'id_tratamiento_paciente': 10,
          'id_medicamento': 8,
          'dosis_diaria': 2.0,
          'frecuencia': 3,
          'duracion': 126,
        };
        expect(result, expectedMap);
      });
    });
  });
}
