import '../../domain/entities/enfermero_resumen_paciente.dart';

class EnfermeroResumenPacienteModel extends EnfermeroResumenPaciente {
  const EnfermeroResumenPacienteModel({
    required super.idPaciente,
    required super.idTratamiento,
    required super.nombrePaciente,
    required super.correoPaciente,
    required super.faseActual,
    required super.estadoTratamiento,
    required super.dosisTomadas,
    required super.dosisTotales,
    required super.dosisHoyTomada,
    required super.reportoSintomasHoy,
    required super.prioridadClinica,
  });
}
