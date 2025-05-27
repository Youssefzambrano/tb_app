class SeguimientoPaciente {
  final int id;
  final int idPaciente;
  final int idTratamientoPaciente;
  final DateTime fechaReporte;
  final int dosisOmitidas;

  const SeguimientoPaciente({
    required this.id,
    required this.idPaciente,
    required this.idTratamientoPaciente,
    required this.fechaReporte,
    required this.dosisOmitidas,
  });
}
