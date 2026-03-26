import '../entities/enfermero_resumen_paciente.dart';
import '../entities/sintoma.dart';

abstract class EnfermeroDashboardRepository {
  Future<List<EnfermeroResumenPaciente>> obtenerResumenPacientesAsignados(
    int idEnfermero,
  );

  Future<void> validarTomaPaciente({
    required int idPaciente,
    required int idTratamientoPaciente,
    required String estado,
  });

  Future<List<Sintoma>> obtenerCatalogoSintomas();

  Future<void> registrarSeguimientoClinico({
    required int idPaciente,
    required int idTratamientoPaciente,
    required int dosisOmitidas,
    required List<int> idsSintomas,
  });
}
