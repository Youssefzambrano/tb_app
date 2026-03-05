import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/administrador_model.dart';
import 'package:tb_app/domain/entities/administrador.dart';

void main() {
  const tAdministradorModel = AdministradorModel(id: 1);

  group('AdministradorModel', () {
    test('debe ser una subclase de la entidad Administrador', () {
      expect(tAdministradorModel, isA<Administrador>());
    });

    test('fromMap debe retornar un modelo válido', () {
      final Map<String, dynamic> map = {'id': 1};
      final result = AdministradorModel.fromMap(map);
      expect(result, tAdministradorModel);
    });

    test('toMap debe retornar un Map con el ID correcto', () {
      final result = tAdministradorModel.toMap();
      expect(result, {'id': 1});
    });
  });
}
