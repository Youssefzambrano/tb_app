abstract class MedicacionRepository {
  Future<int> obtenerIdMedicamentoF1(int idTratamientoPaciente);
  Future<int> obtenerIdMedicamentoF2(int idTratamientoPaciente);
  Future<String> obtenerNombreMedicamento(int idMedicamento);
}
