import '../entities/paciente.dart';

abstract class PacienteRepository {
  /// Inserta un paciente con los datos proporcionados.
  Future<void> registrarPaciente(Paciente paciente);

  /// Obtiene un paciente por su ID (que es el mismo ID del usuario).
  Future<Paciente?> obtenerPacientePorId(int id);

  /// Actualiza los datos del paciente.
  Future<void> actualizarPaciente(Paciente paciente);

  /// Elimina el registro del paciente.
  Future<void> eliminarPaciente(int id);
}
