import '../../domain/entities/paciente.dart';

class PacienteModel extends Paciente {
  const PacienteModel({
    required int id,
    DateTime? fechaDiagnostico,
    String? tipoTuberculosis,
    String? estadoTratamiento,
    required String nombreContactoEmergencia,
    required String telefonoContactoEmergencia,
  }) : super(
         id: id,
         fechaDiagnostico: fechaDiagnostico,
         tipoTuberculosis: tipoTuberculosis,
         estadoTratamiento: estadoTratamiento,
         nombreContactoEmergencia: nombreContactoEmergencia,
         telefonoContactoEmergencia: telefonoContactoEmergencia,
       );

  factory PacienteModel.fromMap(Map<String, dynamic> map) {
    return PacienteModel(
      id: map['id'],
      fechaDiagnostico:
          map['fecha_diagnostico'] != null
              ? DateTime.parse(map['fecha_diagnostico'])
              : null,
      tipoTuberculosis: map['tipo_tuberculosis'],
      estadoTratamiento: map['estado_tratamiento'],
      nombreContactoEmergencia: map['nombre_contacto_emergencia'],
      telefonoContactoEmergencia: map['telefono_contacto_emergencia'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha_diagnostico': fechaDiagnostico?.toIso8601String(),
      'tipo_tuberculosis': tipoTuberculosis ?? 'Sensible',
      'estado_tratamiento': estadoTratamiento ?? 'Activo',
      'nombre_contacto_emergencia': nombreContactoEmergencia,
      'telefono_contacto_emergencia': telefonoContactoEmergencia,
    };
  }
}
