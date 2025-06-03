class TratamientoPaciente {
  final int? id;
  final int idPaciente;
  final String nombre;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFinalizacion;
  final int duracionTotal;
  final String estado;
  final double? pesoPaciente;
  final int totalDosis;
  final int dosisPendientes;
  final bool fase1IntensivaActiva;
  final bool fase2ContinuacionActiva;

  const TratamientoPaciente({
    required this.id,
    required this.idPaciente,
    required this.nombre,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFinalizacion,
    required this.duracionTotal,
    required this.estado,
    this.pesoPaciente,
    required this.totalDosis,
    required this.dosisPendientes,
    required this.fase1IntensivaActiva,
    required this.fase2ContinuacionActiva,
  });
}
