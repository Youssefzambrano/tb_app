import '../repositories/enfermero_dashboard_repository.dart';

class ValidarTomaPacienteEnfermeroUseCase {
  final EnfermeroDashboardRepository repository;

  ValidarTomaPacienteEnfermeroUseCase(this.repository);

  Future<void> call({
    required int idPaciente,
    required int idTratamientoPaciente,
    required String estado,
  }) async {
    await repository.validarTomaPaciente(
      idPaciente: idPaciente,
      idTratamientoPaciente: idTratamientoPaciente,
      estado: estado,
    );
  }
}
