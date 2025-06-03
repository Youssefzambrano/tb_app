import '../../domain/entities/seguimiento_paciente.dart';

class SeguimientoPacienteModel extends SeguimientoPaciente {
  SeguimientoPacienteModel({
    int? id,
    required int idPaciente,
    required int idTratamientoPaciente,
    DateTime? fechaReporte,
    required int dosisOmitidas,
  }) : super(
         id: id,
         idPaciente: idPaciente,
         idTratamientoPaciente: idTratamientoPaciente,
         fechaReporte: fechaReporte ?? DateTime.now(),
         dosisOmitidas: dosisOmitidas,
       );

  factory SeguimientoPacienteModel.fromMap(Map<String, dynamic> map) {
    return SeguimientoPacienteModel(
      id: map['id'],
      idPaciente: map['id_paciente'],
      idTratamientoPaciente: map['id_tratamiento_paciente'],
      fechaReporte: DateTime.parse(map['fecha_reporte']),
      dosisOmitidas: map['dosis_omitidas'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id_paciente': idPaciente,
      'id_tratamiento_paciente': idTratamientoPaciente,
      'fecha_reporte': fechaReporte.toIso8601String(),
      'dosis_omitidas': dosisOmitidas,
    };

    final idValue = super.id;
    if (idValue != null) {
      map['id'] = idValue;
    }

    return map;
  }
}
