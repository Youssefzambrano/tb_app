abstract class AsignacionEnfermeroRemoteDataSource {
  Future<Map<String, dynamic>?> obtenerAsignacionExistente(int idPaciente);

  Future<List<Map<String, dynamic>>> obtenerEnfermeros();

  Future<List<Map<String, dynamic>>> obtenerUsuariosEnfermero();

  Future<int> contarAsignacionesPorEnfermero(int idEnfermero);

  Future<void> insertarAsignacion({
    required int idPaciente,
    required int idEnfermero,
  });

  Future<String?> obtenerNombreUsuario(int idEnfermero);
}
