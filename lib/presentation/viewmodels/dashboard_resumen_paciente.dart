class DashboardPacienteResumen {
  final int dosisTomadas;
  final int dosisTotales;
  final double porcentaje;
  final String faseActual;
  final DateTime? ultimaDosis;
  final bool dosisDeHoyTomada;
  final String medicamentoActual;
  final int diasCompletados;
  final int diasRestantes;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  DashboardPacienteResumen({
    required this.dosisTomadas,
    required this.dosisTotales,
    required this.porcentaje,
    required this.faseActual,
    required this.ultimaDosis,
    required this.dosisDeHoyTomada,
    required this.medicamentoActual,
    required this.diasCompletados,
    required this.diasRestantes,
    required this.fechaInicio,
    required this.fechaFin,
  });
}
