class Paciente {
  final int id;
  final DateTime? fechaDiagnostico;
  final String? tipoTuberculosis;
  final String? estadoTratamiento;
  final String nombreContactoEmergencia;
  final String telefonoContactoEmergencia;

  const Paciente({
    required this.id,
    this.fechaDiagnostico,
    this.tipoTuberculosis,
    this.estadoTratamiento,
    required this.nombreContactoEmergencia,
    required this.telefonoContactoEmergencia,
  });
}
