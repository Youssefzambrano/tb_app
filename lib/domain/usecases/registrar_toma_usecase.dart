import '../entities/dosis.dart';
import '../repositories/dosis_repository.dart';

class RegistrarTomaUseCase {
  final DosisRepository repository;

  RegistrarTomaUseCase(this.repository);

  Future<void> call({
    required int idTratamientoPaciente,
    required int idMedicamento,
    required DateTime fechaHoraToma,
    required String estado,
  }) async {
    final dosis = Dosis(
      id: null,
      idTratamientoPaciente: idTratamientoPaciente,
      idMedicamento: idMedicamento,
      fechaHoraToma: fechaHoraToma,
      estado: estado,
    );

    await repository.registrarDosis(dosis);
  }
}
