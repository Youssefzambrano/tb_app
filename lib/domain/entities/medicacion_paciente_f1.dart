class MedicacionPacienteF1 {
  final int id;
  final int idTratamientoPaciente;
  final int idMedicamento;
  final double dosisDiaria;
  final int frecuencia;
  final int duracion;

  const MedicacionPacienteF1({
    required this.id,
    required this.idTratamientoPaciente,
    required this.idMedicamento,
    required this.dosisDiaria,
    required this.frecuencia,
    required this.duracion,
  });
}
