import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/medicamento_model.dart';
import 'package:tb_app/domain/entities/medicamento.dart';

void main() {
  // Objeto de prueba base
  const tMedicamentoModel = MedicamentoModel(
    id: 1,
    nombre: 'Rifampicina',
    descripcion: 'Antibiótico bactericida',
    dosisRecomendada: 600.0,
    frecuencia: 24,
    duracion: 180,
    laboratorio: 'Genfar',
    cantidadPastillas: 30,
    peso: 0.5,
    efectosSecundarios: 'Náuseas, coloración naranja en orina',
  );

  group('MedicamentoModel', () {
    test('debe ser una subclase de la entidad Medicamento', () {
      expect(tMedicamentoModel, isA<Medicamento>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido cuando los datos del Map son correctos',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'nombre': 'Rifampicina',
            'descripcion': 'Antibiótico bactericida',
            'dosis_recomendada': 600.0,
            'frecuencia': 24,
            'duracion': 180,
            'laboratorio': 'Genfar',
            'cantidad_pastillas': 30,
            'peso': 0.5,
            'efectos_secundarios': 'Náuseas, coloración naranja en orina',
          };

          // Act
          final result = MedicamentoModel.fromMap(map);

          // Assert
          expect(result.id, tMedicamentoModel.id);
          expect(result.nombre, tMedicamentoModel.nombre);
          expect(result.dosisRecomendada, 600.0);
        },
      );

      test(
        'debe convertir valores int a double correctamente para dosis y peso',
        () {
          // Arrange: Aquí simulamos que la DB envía "600" en vez de "600.0"
          final Map<String, dynamic> map = {
            'id': 1,
            'nombre': 'Rifampicina',
            'descripcion': '...',
            'dosis_recomendada': 600, // int
            'frecuencia': 24,
            'duracion': 180,
            'cantidad_pastillas': 30,
            'peso': 1, // int
          };

          // Act
          final result = MedicamentoModel.fromMap(map);

          // Assert
          expect(result.dosisRecomendada, isA<double>());
          expect(result.peso, isA<double>());
          expect(result.peso, 1.0);
        },
      );
    });

    group('toMap', () {
      test('debe retornar un Map conteniendo los datos correctos', () {
        // Act
        final result = tMedicamentoModel.toMap();

        // Assert
        final expectedMap = {
          'id': 1,
          'nombre': 'Rifampicina',
          'descripcion': 'Antibiótico bactericida',
          'dosis_recomendada': 600.0,
          'frecuencia': 24,
          'duracion': 180,
          'laboratorio': 'Genfar',
          'cantidad_pastillas': 30,
          'peso': 0.5,
          'efectos_secundarios': 'Náuseas, coloración naranja en orina',
        };
        expect(result, expectedMap);
      });
    });
  });
}
