import 'dart:math';
import '../../domain/entities/asignacion_enfermero_resultado.dart';
import '../../domain/repositories/asignacion_enfermero_repository.dart';
import '../datasources/remote/supabase/asignacion_enfermero_remote_datasource.dart';

int seleccionarEnfermeroBalanceado({
  required List<Map<String, dynamic>> cargas,
  required Random random,
}) {
  if (cargas.isEmpty) {
    throw StateError('No hay enfermeros disponibles para asignar.');
  }

  final ordenadas = [...cargas]
    ..sort((a, b) => (a['total'] as int).compareTo(b['total'] as int));

  final minCarga = ordenadas.first['total'] as int;
  final candidatos = ordenadas.where((c) => c['total'] == minCarga).toList();
  final seleccionado = candidatos[random.nextInt(candidatos.length)];

  return seleccionado['id_enfermero'] as int;
}

class AsignacionEnfermeroRepositoryImpl
    implements AsignacionEnfermeroRepository {
  final AsignacionEnfermeroRemoteDataSource remoteDataSource;
  final Random random;

  AsignacionEnfermeroRepositoryImpl({
    required this.remoteDataSource,
    Random? random,
  }) : random = random ?? Random();

  @override
  Future<AsignacionEnfermeroResultado?> asignarEnfermeroBalanceado({
    required int idPaciente,
  }) async {
    final asignacionExistente = await remoteDataSource
        .obtenerAsignacionExistente(idPaciente);

    if (asignacionExistente != null &&
        asignacionExistente['id_enfermero'] != null) {
      final idEnfermeroExistente = asignacionExistente['id_enfermero'] as int;
      final nombreExistente = await remoteDataSource.obtenerNombreUsuario(
        idEnfermeroExistente,
      );

      return AsignacionEnfermeroResultado(
        idEnfermero: idEnfermeroExistente,
        nombreEnfermero: nombreExistente,
      );
    }

    var enfermeros = await remoteDataSource.obtenerEnfermeros();

    if (enfermeros.isEmpty) {
      enfermeros = await remoteDataSource.obtenerUsuariosEnfermero();
    }

    if (enfermeros.isEmpty) return null;

    final cargas = <Map<String, dynamic>>[];

    for (final enfermero in enfermeros) {
      final idEnfermero = enfermero['id'] as int;
      final total = await remoteDataSource.contarAsignacionesPorEnfermero(
        idEnfermero,
      );

      cargas.add({
        'id_enfermero': idEnfermero,
        'nombre_enfermero': enfermero['nombre_enfermero'] as String?,
        'total': total,
      });
    }

    final idEnfermeroSeleccionado = seleccionarEnfermeroBalanceado(
      cargas: cargas,
      random: random,
    );

    try {
      await remoteDataSource.insertarAsignacion(
        idPaciente: idPaciente,
        idEnfermero: idEnfermeroSeleccionado,
      );
    } catch (e) {
      throw Exception('Error al insertar asignacion paciente-enfermero: $e');
    }

    final seleccionado = cargas.firstWhere(
      (c) => c['id_enfermero'] == idEnfermeroSeleccionado,
      orElse:
          () => {
            'id_enfermero': idEnfermeroSeleccionado,
            'nombre_enfermero': null,
          },
    );

    String? nombre = seleccionado['nombre_enfermero'] as String?;
    if (nombre == null || nombre.trim().isEmpty) {
      nombre = await remoteDataSource.obtenerNombreUsuario(
        idEnfermeroSeleccionado,
      );
    }

    return AsignacionEnfermeroResultado(
      idEnfermero: idEnfermeroSeleccionado,
      nombreEnfermero: nombre,
    );
  }
}
