class MedicacionPacienteF2 {
  final int id;
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
}
