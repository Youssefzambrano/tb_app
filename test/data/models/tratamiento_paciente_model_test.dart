import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/tratamiento_paciente_model.dart';
import 'package:tb_app/domain/entities/tratamiento_paciente.dart';

void main() {
  final tFechaInicio = DateTime(2024, 1, 1);
  final tFechaFase1 = DateTime(2024, 1, 2);

  final tTratamientoModel = TratamientoPacienteModel(
    id: 1,
    idPaciente: 101,
    nombre: 'Tratamiento Estándar',
    descripcion: '6 meses',
    fechaInicio: tFechaInicio,
    duracionTotal: 180,
    estado: 'En curso',
    pesoPaciente: 70.5,
    totalDosis: 150,
    dosisPendientes: 140,
    fase1IntensivaActiva: true,
    fase2ContinuacionActiva: false,
    fechaInicioFase1: tFechaFase1,
  );

  group('TratamientoPacienteModel', () {
    test('debe ser una subclase de la entidad TratamientoPaciente', () {
      expect(tTratamientoModel, isA<TratamientoPaciente>());
    });

    group('fromMap', () {
      test(
        'debe retornar un modelo válido con todos los campos (incluyendo fechas opcionales)',
        () {
          final Map<String, dynamic> map = {
            'id': 1,
            'id_paciente': 101,
            'nombre': 'Tratamiento Estándar',
            'descripcion': '6 meses',
            'fecha_inicio': '2024-01-01T00:00:00.000',
            'fecha_finalizacion': null,
            'duracion_total': 180,
            'estado': 'En curso',
            'peso_paciente': 70.5,
            'total_dosis': 150,
            'dosis_pendientes': 140,
            'fase1_intensiva_activa': true,
            'fase2_continuacion_activa': false,
            'fecha_inicio_fase1': '2024-01-02T00:00:00.000',
            'fecha_inicio_fase2': null,
          };

          final result = TratamientoPacienteModel.fromMap(map);

          expect(result.id, 1);
          expect(result.fechaInicio, tFechaInicio);
          expect(result.fechaInicioFase1, tFechaFase1);
          expect(result.fechaFinalizacion, null);
        },
      );
    });

    group('fromEntity', () {
      test('debe crear un Modelo a partir de una Entidad correctamente', () {
        // Usamos la misma instancia de prueba como entidad
        final result = TratamientoPacienteModel.fromEntity(tTratamientoModel);

        expect(result.nombre, tTratamientoModel.nombre);
        expect(result.idPaciente, tTratamientoModel.idPaciente);
        expect(result.fase1IntensivaActiva, true);
      });
    });

    group('toMap', () {
      test('debe retornar un Map con el formato correcto de base de datos', () {
        final result = tTratamientoModel.toMap();

        expect(result['id_paciente'], 101);
        expect(result['fecha_inicio'], tFechaInicio.toIso8601String());
        expect(result['id'], 1);
      });

      test('no debe incluir la llave "id" si es nulo', () {
        final tTratamientoSinId = TratamientoPacienteModel(
          id: null,
          idPaciente: 1,
          nombre: 'Test',
          fechaInicio: tFechaInicio,
          duracionTotal: 30,
          estado: 'Activo',
          totalDosis: 30,
          dosisPendientes: 30,
          fase1IntensivaActiva: true,
          fase2ContinuacionActiva: false,
        );

        final result = tTratamientoSinId.toMap();
        expect(result.containsKey('id'), false);
      });
    });
  });
}
