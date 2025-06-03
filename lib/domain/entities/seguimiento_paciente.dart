class SeguimientoPaciente {
  final int? id;
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

  SeguimientoPaciente copyWith({
    int? id,
    int? idPaciente,
    int? idTratamientoPaciente,
    DateTime? fechaReporte,
    int? dosisOmitidas,
  }) {
    return SeguimientoPaciente(
      id: id ?? this.id,
      idPaciente: idPaciente ?? this.idPaciente,
      idTratamientoPaciente:
          idTratamientoPaciente ?? this.idTratamientoPaciente,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      dosisOmitidas: dosisOmitidas ?? this.dosisOmitidas,
    );
  }
}
