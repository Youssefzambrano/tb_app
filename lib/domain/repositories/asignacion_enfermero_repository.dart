import '../entities/asignacion_enfermero_resultado.dart';

abstract class AsignacionEnfermeroRepository {
  Future<AsignacionEnfermeroResultado?> asignarEnfermeroBalanceado({
    required int idPaciente,
  });
}
