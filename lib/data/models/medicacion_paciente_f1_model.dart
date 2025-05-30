import '../../domain/entities/medicacion_paciente_f1.dart';

class MedicacionPacienteF1Model extends MedicacionPacienteF1 {
  const MedicacionPacienteF1Model({
    required int id,
    required int idTratamientoPaciente,
    required int idMedicamento,
    required double dosisDiaria,
    required int frecuencia,
    int duracion = 56,
  }) : super(
         id: id,
         idTratamientoPaciente: idTratamientoPaciente,
         idMedicamento: idMedicamento,
         dosisDiaria: dosisDiaria,
         frecuencia: frecuencia,
         duracion: duracion,
       );

  factory MedicacionPacienteF1Model.fromMap(Map<String, dynamic> map) {
    return MedicacionPacienteF1Model(
      id: map['id'],
      idTratamientoPaciente: map['id_tratamiento_paciente'],
      idMedicamento: map['id_medicamento'],
      dosisDiaria: map['dosis_diaria'].toDouble(),
      frecuencia: map['frecuencia'],
      duracion: map['duracion'] ?? 56,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_tratamiento_paciente': idTratamientoPaciente,
      'id_medicamento': idMedicamento,
      'dosis_diaria': dosisDiaria,
      'frecuencia': frecuencia,
      'duracion': duracion,
    };
  }
}
