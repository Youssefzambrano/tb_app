import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dosis.dart';
import '../../domain/repositories/dosis_repository.dart';
import '../models/dosis_model.dart';

class DosisRepositoryImpl implements DosisRepository {
  final SupabaseClient supabase;

  DosisRepositoryImpl({required this.supabase});

  @override
  Future<void> registrarDosis(Dosis dosis) async {
    final model = DosisModel(
      id: null, // será descartado si es generado automáticamente
      idTratamientoPaciente: dosis.idTratamientoPaciente,
      idMedicamento: dosis.idMedicamento,
      fechaHoraToma: dosis.fechaHoraToma,
      estado: dosis.estado,
    );

    final map = model.toMap();
    map.remove('id'); // No incluir el id si es autogenerado

    await supabase.from('dosis').insert(map);
  }

  @override
  Future<int> contarDosisPorUsuario(int idUsuario) async {
    final response = await supabase
        .from('dosis')
        .select('id_tratamiento_paciente!inner(id_paciente)')
        .eq('id_tratamiento_paciente.id_paciente', idUsuario);

    return response.length;
  }

  @override
  Future<Dosis?> obtenerUltimaDosis(int idPaciente) async {
    final data =
        await supabase
            .from('dosis')
            .select('*, id_tratamiento_paciente(id_paciente)')
            .eq('id_tratamiento_paciente.id_paciente', idPaciente)
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
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = inicioDia
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final response = await supabase
        .from('dosis')
        .select('id, id_tratamiento_paciente(id_paciente)')
        .gte('fecha_hora_toma', inicioDia.toIso8601String())
        .lte('fecha_hora_toma', finDia.toIso8601String())
        .eq('id_tratamiento_paciente.id_paciente', idPaciente);

    return response.isNotEmpty;
  }
}
