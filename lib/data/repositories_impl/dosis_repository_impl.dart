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
}
