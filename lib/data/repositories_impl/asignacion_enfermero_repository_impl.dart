import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/asignacion_enfermero_resultado.dart';
import '../../domain/repositories/asignacion_enfermero_repository.dart';

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

class AsignacionEnfermeroRepositoryImpl implements AsignacionEnfermeroRepository {
  final SupabaseClient supabase;
  final Random random;

  AsignacionEnfermeroRepositoryImpl({
    required this.supabase,
    Random? random,
  }) : random = random ?? Random();

  @override
  Future<AsignacionEnfermeroResultado?> asignarEnfermeroBalanceado({
    required int idPaciente,
  }) async {
    final asignacionExistente = await supabase
        .from('paciente_enfermero')
        .select('id_enfermero')
        .eq('id_paciente', idPaciente)
        .maybeSingle();

    if (asignacionExistente != null &&
        asignacionExistente['id_enfermero'] != null) {
      final idEnfermeroExistente = asignacionExistente['id_enfermero'] as int;
      final nombreExistente = await _obtenerNombreEnfermero(idEnfermeroExistente);
      return AsignacionEnfermeroResultado(
        idEnfermero: idEnfermeroExistente,
        nombreEnfermero: nombreExistente,
      );
    }

    final enfermerosTabla = await supabase
        .from('enfermero')
        .select('id, nombre_enfermero');

    List<Map<String, dynamic>> enfermeros =
        (enfermerosTabla as List).cast<Map<String, dynamic>>();

    // Fallback: si la tabla enfermero no tiene filas, usa usuarios por rol.
    if (enfermeros.isEmpty) {
      final usuariosEnfermero = await supabase
          .from('usuario')
          .select('id, nombre')
          .or(
            'nivel_acceso.eq.Enfermero,nivel_acceso.eq.enfermero,nivel_acceso.eq.ENFERMERO',
          );

      enfermeros = (usuariosEnfermero as List)
          .map(
            (u) => {
              'id': u['id'],
              'nombre_enfermero': u['nombre'],
            },
          )
          .cast<Map<String, dynamic>>()
          .toList();
    }

    if (enfermeros.isEmpty) return null;

    final cargas = <Map<String, dynamic>>[];

    for (final enfermero in enfermeros) {
      final int idEnfermero = enfermero['id'] as int;
      final asignaciones = await supabase
          .from('paciente_enfermero')
          .select('id')
          .eq('id_enfermero', idEnfermero);

      cargas.add({
        'id_enfermero': idEnfermero,
        'nombre_enfermero': enfermero['nombre_enfermero'] as String?,
        'total': (asignaciones as List).length,
      });
    }

    final int idEnfermeroSeleccionado = seleccionarEnfermeroBalanceado(
      cargas: cargas,
      random: random,
    );

    try {
      await supabase.from('paciente_enfermero').insert({
        'id_paciente': idPaciente,
        'id_enfermero': idEnfermeroSeleccionado,
      });
    } catch (e) {
      throw Exception('Error al insertar asignacion paciente-enfermero: $e');
    }

    final seleccionado = cargas.firstWhere(
      (c) => c['id_enfermero'] == idEnfermeroSeleccionado,
      orElse: () => {'id_enfermero': idEnfermeroSeleccionado, 'nombre_enfermero': null},
    );

    String? nombre = seleccionado['nombre_enfermero'] as String?;
    if (nombre == null || nombre.trim().isEmpty) {
      nombre = await _obtenerNombreEnfermero(idEnfermeroSeleccionado);
    }

    return AsignacionEnfermeroResultado(
      idEnfermero: idEnfermeroSeleccionado,
      nombreEnfermero: nombre,
    );
  }

  Future<String?> _obtenerNombreEnfermero(int idEnfermero) async {
    final usuario = await supabase
        .from('usuario')
        .select('nombre')
        .eq('id', idEnfermero)
        .maybeSingle();
    return usuario?['nombre'] as String?;
  }
}
