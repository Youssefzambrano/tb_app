import '../../domain/entities/sintoma_paciente.dart';

class SintomaPacienteModel extends SintomaPaciente {
  const SintomaPacienteModel({
    required int id,
    required int idSeguimiento,
    required int idSintoma,
    required DateTime fechaRegistro,
  }) : super(
         id: id,
         idSeguimiento: idSeguimiento,
         idSintoma: idSintoma,
         fechaRegistro: fechaRegistro,
       );

  factory SintomaPacienteModel.fromMap(Map<String, dynamic> map) {
    return SintomaPacienteModel(
      id: map['id'],
      idSeguimiento: map['id_seguimiento'],
      idSintoma: map['id_sintoma'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_seguimiento': idSeguimiento,
      'id_sintoma': idSintoma,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}
