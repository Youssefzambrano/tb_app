import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/paciente_model.dart';
import 'package:tb_app/domain/entities/paciente.dart';

void main() {
  // Objeto de prueba base
  final tPacienteModel = PacienteModel(
    id: 1,
    fechaDiagnostico: DateTime(2023, 5, 20),
    tipoTuberculosis: 'Sensible',
    estadoTratamiento: 'Activo',
    nombreContactoEmergencia: 'Maria Doe',
    telefonoContactoEmergencia: '987654321',
  );

  group('PacienteModel', () {
    test('debe ser una subclase de la entidad Paciente', () {
      expect(tPacienteModel, isA<Paciente>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido cuando el Map tiene todos los campos',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'fecha_diagnostico': '2023-05-20T00:00:00.000',
            'tipo_tuberculosis': 'Sensible',
            'estado_tratamiento': 'Activo',
            'nombre_contacto_emergencia': 'Maria Doe',
            'telefono_contacto_emergencia': '987654321',
          };

          // Act
          final result = PacienteModel.fromMap(map);

          // Assert
          expect(result.id, tPacienteModel.id);
          expect(
            result.nombreContactoEmergencia,
            tPacienteModel.nombreContactoEmergencia,
          );
          expect(result.fechaDiagnostico, isA<DateTime>());
        },
      );

      test(
        'debe manejar campos nulos correctamente al convertir desde Map',
        () {
          // Arrange
          final Map<String, dynamic> map = {
            'id': 1,
            'fecha_diagnostico': null, // Probamos el null
            'tipo_tuberculosis': null,
            'estado_tratamiento': null,
            'nombre_contacto_emergencia': 'Maria Doe',
            'telefono_contacto_emergencia': '987654321',
          };

          // Act
          final result = PacienteModel.fromMap(map);

          // Assert
          expect(result.fechaDiagnostico, null);
          expect(result.tipoTuberculosis, null);
        },
      );
    });

    group('toMap', () {
      test(
        'debe retornar un Map con los valores por defecto cuando los campos opcionales son nulos',
        () {
          // Arrange
          const tPacienteModelSinOpcionales = PacienteModel(
            id: 1,
            nombreContactoEmergencia: 'Maria Doe',
            telefonoContactoEmergencia: '987654321',
          );

          // Act
          final result = tPacienteModelSinOpcionales.toMap();

          // Assert
          expect(result['tipo_tuberculosis'], 'Sensible'); // Valor por defecto
          expect(
            result['estado_treatmento'] ?? result['estado_tratamiento'],
            'Activo',
          ); // Valor por defecto
        },
      );
    });
  });
}
