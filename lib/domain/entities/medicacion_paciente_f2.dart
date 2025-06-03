class MedicacionPacienteF2 {
  final int? id;
  final int idTratamientoPaciente;
  final int idMedicamento;
  final double dosisDiaria;
  final int frecuencia;
  final int duracion;

  const MedicacionPacienteF2({
    required this.id,
    required this.idTratamientoPaciente,
    required this.idMedicamento,
    required this.dosisDiaria,
    required this.frecuencia,
    this.duracion = 112,
  });

  MedicacionPacienteF2 copyWith({
    int? id,
    int? idTratamientoPaciente,
    int? idMedicamento,
    double? dosisDiaria,
    int? frecuencia,
    int? duracion,
  }) {
    return MedicacionPacienteF2(
      id: id ?? this.id,
      idTratamientoPaciente:
          idTratamientoPaciente ?? this.idTratamientoPaciente,
      idMedicamento: idMedicamento ?? this.idMedicamento,
      dosisDiaria: dosisDiaria ?? this.dosisDiaria,
      frecuencia: frecuencia ?? this.frecuencia,
      duracion: duracion ?? this.duracion,
    );
  }
}
