import '../repositories/enfermero_dashboard_repository.dart';

class RegistrarSeguimientoClinicoUseCase {
  final EnfermeroDashboardRepository repository;

  RegistrarSeguimientoClinicoUseCase(this.repository);

  Future<void> call({
    required int idPaciente,
    required int idTratamientoPaciente,
    required int dosisOmitidas,
    required List<int> idsSintomas,
  }) async {
    await repository.registrarSeguimientoClinico(
      idPaciente: idPaciente,
      idTratamientoPaciente: idTratamientoPaciente,
      dosisOmitidas: dosisOmitidas,
      idsSintomas: idsSintomas,
    );
  }
}
