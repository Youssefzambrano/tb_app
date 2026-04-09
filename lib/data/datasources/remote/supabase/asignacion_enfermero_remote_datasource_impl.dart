import 'package:supabase_flutter/supabase_flutter.dart';
import 'asignacion_enfermero_remote_datasource.dart';

class AsignacionEnfermeroRemoteDataSourceImpl
    implements AsignacionEnfermeroRemoteDataSource {
  final SupabaseClient supabase;

  AsignacionEnfermeroRemoteDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>?> obtenerAsignacionExistente(
    int idPaciente,
  ) async {
    return await supabase
        .from('paciente_enfermero')
        .select('id_enfermero')
        .eq('id_paciente', idPaciente)
        .maybeSingle();
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerEnfermeros() async {
    final data = await supabase
        .from('enfermero')
        .select('id, nombre_enfermero');
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerUsuariosEnfermero() async {
    final data = await supabase
        .from('usuario')
        .select('id, nombre')
        .or(
          'nivel_acceso.eq.Enfermero,nivel_acceso.eq.enfermero,nivel_acceso.eq.ENFERMERO',
        );

    return (data as List)
        .map((u) => {'id': u['id'], 'nombre_enfermero': u['nombre']})
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Future<int> contarAsignacionesPorEnfermero(int idEnfermero) async {
    final data = await supabase
        .from('paciente_enfermero')
        .select('id')
        .eq('id_enfermero', idEnfermero);

    return (data as List).length;
  }

  @override
  Future<void> insertarAsignacion({
    required int idPaciente,
    required int idEnfermero,
  }) async {
    await supabase.from('paciente_enfermero').insert({
      'id_paciente': idPaciente,
      'id_enfermero': idEnfermero,
    });
  }

  @override
  Future<String?> obtenerNombreUsuario(int idEnfermero) async {
    final usuario =
        await supabase
            .from('usuario')
            .select('nombre')
            .eq('id', idEnfermero)
            .maybeSingle();

    return usuario?['nombre'] as String?;
  }
}
