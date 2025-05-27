class Dosis {
  final int id;
  final int idTratamientoPaciente;
  final int idMedicamento;
  final DateTime fechaHoraToma;
  final String estado;

  const Dosis({
    required this.id,
    required this.idTratamientoPaciente,
    required this.idMedicamento,
    required this.fechaHoraToma,
    required this.estado,
  });
}
