import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/sintoma_model.dart';
import 'package:tb_app/domain/entities/sintoma.dart';

void main() {
  // Definimos una constante para comparar
  const tSintomaModel = SintomaModel(id: 1, nombre: 'Tos persistente');

  group('SintomaModel', () {
    test('debe ser una subclase de la entidad Sintoma', () {
      expect(tSintomaModel, isA<Sintoma>());
    });

    test('fromMap debe retornar un modelo válido', () {
      final Map<String, dynamic> map = {'id': 1, 'nombre': 'Tos persistente'};

      final result = SintomaModel.fromMap(map);

      // Ahora esto pasará a verde porque usamos Equatable
      expect(result, tSintomaModel);
    });

    test('toMap debe retornar un Map con los datos correctos', () {
      final result = tSintomaModel.toMap();
      final expectedMap = {'id': 1, 'nombre': 'Tos persistente'};
      expect(result, expectedMap);
    });
  });
}
