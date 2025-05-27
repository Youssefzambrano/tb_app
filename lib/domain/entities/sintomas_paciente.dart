class SintomasPaciente {
  final int id;
  final int idSeguimiento;
  final int idSintoma;
  final DateTime fechaRegistro;

  const SintomasPaciente({
    required this.id,
    required this.idSeguimiento,
    required this.idSintoma,
    required this.fechaRegistro,
  });
}
