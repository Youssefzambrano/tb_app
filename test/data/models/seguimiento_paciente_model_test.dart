import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/seguimiento_paciente_model.dart';
import 'package:tb_app/domain/entities/seguimiento_paciente.dart';

void main() {
  final tFecha = DateTime(2024, 1, 1, 10, 0);

  final tSeguimientoModel = SeguimientoPacienteModel(
    id: 1,
    idPaciente: 100,
    idTratamientoPaciente: 50,
    fechaReporte: tFecha,
    dosisOmitidas: 0,
  );

  group('SeguimientoPacienteModel', () {
    test('debe ser una subclase de la entidad SeguimientoPaciente', () {
      expect(tSeguimientoModel, isA<SeguimientoPaciente>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido con los datos de la base de datos',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'id_paciente': 100,
            'id_tratamiento_paciente': 50,
            'fecha_reporte': '2024-01-01T10:00:00.000',
            'dosis_omitidas': 0,
          };

          // Act
          final result = SeguimientoPacienteModel.fromMap(map);

          // Assert
          expect(result.id, tSeguimientoModel.id);
          expect(result.idPaciente, tSeguimientoModel.idPaciente);
          expect(result.fechaReporte, tFecha);
        },
      );
    });

    group('toMap', () {
      test('debe retornar un Map con las llaves en snake_case correctas', () {
        // Act
        final result = tSeguimientoModel.toMap();

        // Assert
        final expectedMap = {
          'id': 1,
          'id_paciente': 100,
          'id_tratamiento_paciente': 50,
          'fecha_reporte': '2024-01-01T10:00:00.000',
          'dosis_omitidas': 0,
        };
        expect(result, expectedMap);
      });

      test(
        'debe generar una fecha actual si fechaReporte es nulo en el constructor',
        () {
          // Arrange
          final seguimientoSinFecha = SeguimientoPacienteModel(
            idPaciente: 1,
            idTratamientoPaciente: 1,
            dosisOmitidas: 2,
            fechaReporte: null, // Forzamos el uso de DateTime.now()
          );

          // Act & Assert
          expect(seguimientoSinFecha.fechaReporte, isA<DateTime>());
          // Verificamos que la fecha generada sea de hoy (mismo año/mes/día)
          final ahora = DateTime.now();
          expect(seguimientoSinFecha.fechaReporte.year, ahora.year);
          expect(seguimientoSinFecha.fechaReporte.month, ahora.month);
        },
      );
    });
  });
}
