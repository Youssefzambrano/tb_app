import 'package:equatable/equatable.dart';
import '../../domain/entities/paciente_enfermero.dart';

class PacienteEnfermeroModel extends PacienteEnfermero with EquatableMixin {
  const PacienteEnfermeroModel({
    required int id,
    required int idPaciente,
    required int idEnfermero,
  }) : super(id: id, idPaciente: idPaciente, idEnfermero: idEnfermero);

  @override
  List<Object?> get props => [id, idPaciente, idEnfermero];

  factory PacienteEnfermeroModel.fromMap(Map<String, dynamic> map) {
    return PacienteEnfermeroModel(
      id: map['id'],
      idPaciente: map['id_paciente'],
      idEnfermero: map['id_enfermero'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'id_paciente': idPaciente, 'id_enfermero': idEnfermero};
  }
}
