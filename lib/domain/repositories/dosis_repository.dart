import '../entities/dosis.dart';

abstract class DosisRepository {
  /// Inserta una nueva dosis registrada por el paciente
  Future<void> registrarDosis(Dosis dosis);

  /// Consulta la cantidad total de dosis registradas por un usuario específico
  Future<int> contarDosisPorUsuario(int idUsuario);
}
