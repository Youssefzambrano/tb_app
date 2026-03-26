import '../entities/enfermero_resumen_paciente.dart';
import '../repositories/enfermero_dashboard_repository.dart';

class ObtenerDashboardEnfermeroUseCase {
  final EnfermeroDashboardRepository repository;

  ObtenerDashboardEnfermeroUseCase(this.repository);

  Future<List<EnfermeroResumenPaciente>> call(int idEnfermero) async {
    final resumenes = await repository.obtenerResumenPacientesAsignados(
      idEnfermero,
    );

    resumenes.sort((a, b) {
      final porPrioridad = b.prioridadClinica.compareTo(a.prioridadClinica);
      if (porPrioridad != 0) return porPrioridad;
      return a.adherencia.compareTo(b.adherencia);
    });

    return resumenes;
  }
}
