import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dosis.dart';
import '../../domain/repositories/dosis_repository.dart';
import '../models/dosis_model.dart';

class DosisRepositoryImpl implements DosisRepository {
  final SupabaseClient supabase;

  DosisRepositoryImpl({required this.supabase});

  Future<int?> _obtenerIdTratamientoActivo(int idPaciente) async {
    final data =
        await supabase
            .from('tratamiento_paciente')
            .select('id')
            .eq('id_paciente', idPaciente)
            .eq('estado', 'En curso')
            .maybeSingle();
    return data?['id'] as int?;
  }

  @override
  Future<void> registrarDosis(Dosis dosis) async {
    final model = DosisModel(
      id: null,
      idTratamientoPaciente: dosis.idTratamientoPaciente,
      idMedicamento: dosis.idMedicamento,
      fechaHoraToma: dosis.fechaHoraToma,
      estado: dosis.estado,
    );
    final map = model.toMap();
    map.remove('id');
    await supabase.from('dosis').insert(map);
  }

  @override
  Future<int> contarDosisPorUsuario(int idUsuario) async {
    final idTratamiento = await _obtenerIdTratamientoActivo(idUsuario);
    if (idTratamiento == null) return 0;

    final response = await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento);

    return response.length;
  }

  @override
  Future<Dosis?> obtenerUltimaDosis(int idPaciente) async {
    final idTratamiento = await _obtenerIdTratamientoActivo(idPaciente);
    if (idTratamiento == null) return null;

    final data =
        await supabase
            .from('dosis')
            .select('*')
            .eq('id_tratamiento_paciente', idTratamiento)
            .order('fecha_hora_toma', ascending: false)
            .limit(1)
            .maybeSingle();

    if (data == null) return null;
    try {
      return DosisModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> existeDosisHoy(int idPaciente) async {
    final idTratamiento = await _obtenerIdTratamientoActivo(idPaciente);
    if (idTratamiento == null) return false;

    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = inicioDia
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final response = await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento)
        .gte('fecha_hora_toma', inicioDia.toIso8601String())
        .lte('fecha_hora_toma', finDia.toIso8601String());

    return response.isNotEmpty;
  }
}
