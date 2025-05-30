class SintomaPaciente {
  final int id;
  final int idSeguimiento;
  final int idSintoma;
  final DateTime fechaRegistro;

  const SintomaPaciente({
    required this.id,
    required this.idSeguimiento,
    required this.idSintoma,
    required this.fechaRegistro,
  });
}
