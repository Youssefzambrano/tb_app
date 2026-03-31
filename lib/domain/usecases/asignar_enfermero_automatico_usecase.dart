import '../entities/asignacion_enfermero_resultado.dart';
import '../repositories/asignacion_enfermero_repository.dart';

class AsignarEnfermeroAutomaticoUseCase {
  final AsignacionEnfermeroRepository repository;

  AsignarEnfermeroAutomaticoUseCase(this.repository);

  Future<AsignacionEnfermeroResultado?> call({required int idPaciente}) async {
    return await repository.asignarEnfermeroBalanceado(idPaciente: idPaciente);
  }
}
