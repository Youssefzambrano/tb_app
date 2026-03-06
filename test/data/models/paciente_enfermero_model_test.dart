import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/paciente_enfermero_model.dart';
import 'package:tb_app/domain/entities/paciente_enfermero.dart';

void main() {
  const tPacienteEnfermeroModel = PacienteEnfermeroModel(
    id: 1,
    idPaciente: 101,
    idEnfermero: 202,
  );

  group('PacienteEnfermeroModel', () {
    test('debe ser una subclase de la entidad PacienteEnfermero', () {
      expect(tPacienteEnfermeroModel, isA<PacienteEnfermero>());
    });

    group('fromMap', () {
      test('debe retornar un modelo válido desde el Map', () {
        final Map<String, dynamic> map = {
          'id': 1,
          'id_paciente': 101,
          'id_enfermero': 202,
        };

        final result = PacienteEnfermeroModel.fromMap(map);

        expect(result, tPacienteEnfermeroModel);
      });
    });

    group('toMap', () {
      test('debe retornar un Map con las llaves correctas (snake_case)', () {
        final result = tPacienteEnfermeroModel.toMap();

        final expectedMap = {'id': 1, 'id_paciente': 101, 'id_enfermero': 202};

        expect(result, expectedMap);
      });
    });
  });
}
