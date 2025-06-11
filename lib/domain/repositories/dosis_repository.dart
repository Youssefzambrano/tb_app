import '../entities/dosis.dart';

abstract class DosisRepository {
  /// Inserta una nueva dosis registrada por el paciente
  Future<void> registrarDosis(Dosis dosis);

  /// Consulta la cantidad total de dosis registradas por un usuario específico
  Future<int> contarDosisPorUsuario(int idUsuario);

  /// Consulta la última dosis registrada por un paciente
  Future<Dosis?> obtenerUltimaDosis(int idPaciente);

  /// Verifica si el paciente ya registró una dosis para el día actual
  Future<bool> existeDosisHoy(int idPaciente);
}
