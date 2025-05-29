import '../entities/paciente.dart';
import '../repositories/paciente_repository.dart';

class RegistrarPacienteUseCase {
  final PacienteRepository repository;

  RegistrarPacienteUseCase(this.repository);

  Future<void> call({
    required int idUsuario,
    required String nombreContacto,
    required String telefonoContacto,
  }) async {
    final paciente = Paciente(
      id: idUsuario,
      fechaDiagnostico: null,
      tipoTuberculosis: 'Sensible',
      estadoTratamiento: 'Activo',
      nombreContactoEmergencia: nombreContacto,
      telefonoContactoEmergencia: telefonoContacto,
    );

    await repository.registrarPaciente(paciente);
  }
}
