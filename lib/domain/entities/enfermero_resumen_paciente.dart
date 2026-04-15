class EnfermeroResumenPaciente {
  final int idPaciente;
  final int? idTratamiento;
  final String nombrePaciente;
  final String correoPaciente;
  final String numeroDocumento;
  final String faseActual;
  final String estadoTratamiento;
  final int dosisTomadas;
  final int dosisTotales;
  final bool dosisHoyTomada;
  final bool reportoSintomasHoy;
  final int prioridadClinica;

  const EnfermeroResumenPaciente({
    required this.idPaciente,
    required this.idTratamiento,
    required this.nombrePaciente,
    required this.correoPaciente,
    required this.numeroDocumento,
    required this.faseActual,
    required this.estadoTratamiento,
    required this.dosisTomadas,
    required this.dosisTotales,
    required this.dosisHoyTomada,
    required this.reportoSintomasHoy,
    required this.prioridadClinica,
  });

  double get adherencia {
    if (dosisTotales <= 0) return 0;
    return (dosisTomadas / dosisTotales) * 100;
  }

  bool get tieneAlerta => reportoSintomasHoy || !dosisHoyTomada;
}
