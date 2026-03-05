import 'package:equatable/equatable.dart';
import '../../domain/entities/medicacion_paciente_f2.dart';

class MedicacionPacienteF2Model extends MedicacionPacienteF2
    with EquatableMixin {
  const MedicacionPacienteF2Model({
    int? id,
    required int idTratamientoPaciente,
    required int idMedicamento,
    required double dosisDiaria,
    required int frecuencia,
    int duracion =
        56, // Nota: Verifica si para F2 la duración estándar cambia a 112 o 126 días según tu protocolo.
  }) : super(
         id: id,
         idTratamientoPaciente: idTratamientoPaciente,
         idMedicamento: idMedicamento,
         dosisDiaria: dosisDiaria,
         frecuencia: frecuencia,
         duracion: duracion,
       );

  @override
  List<Object?> get props => [
    id,
    idTratamientoPaciente,
    idMedicamento,
    dosisDiaria,
    frecuencia,
    duracion,
  ];

  factory MedicacionPacienteF2Model.fromMap(Map<String, dynamic> map) {
    return MedicacionPacienteF2Model(
      id: map['id'],
      idTratamientoPaciente: map['id_tratamiento_paciente'],
      idMedicamento: map['id_medicamento'],
      dosisDiaria: (map['dosis_diaria'] as num).toDouble(),
      frecuencia: map['frecuencia'],
      duracion: map['duracion'] ?? 56,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'id_tratamiento_paciente': idTratamientoPaciente,
      'id_medicamento': idMedicamento,
      'dosis_diaria': dosisDiaria,
      'frecuencia': frecuencia,
      'duracion': duracion,
    };
  }
}
