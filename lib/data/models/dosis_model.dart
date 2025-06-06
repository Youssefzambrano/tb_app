import '../../domain/entities/dosis.dart';

class DosisModel extends Dosis {
  const DosisModel({
    required int? id, // ✅ Campo opcional, sin required
    required int idTratamientoPaciente,
    required int idMedicamento,
    required DateTime fechaHoraToma,
    required String estado,
  }) : super(
         id: id,
         idTratamientoPaciente: idTratamientoPaciente,
         idMedicamento: idMedicamento,
         fechaHoraToma: fechaHoraToma,
         estado: estado,
       );

  factory DosisModel.fromMap(Map<String, dynamic> map) {
    return DosisModel(
      id: map['id'],
      idTratamientoPaciente: map['id_tratamiento_paciente'],
      idMedicamento: map['id_medicamento'],
      fechaHoraToma: DateTime.parse(map['fecha_hora_toma']),
      estado: map['estado'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id_tratamiento_paciente': idTratamientoPaciente,
      'id_medicamento': idMedicamento,
      'fecha_hora_toma': fechaHoraToma.toIso8601String(),
      'estado': estado,
    };

    final idValue = super.id;
    if (idValue != null) {
      map['id'] = idValue;
    }

    return map;
  }
}
