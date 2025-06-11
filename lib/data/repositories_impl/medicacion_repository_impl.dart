import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/medicacion_repository.dart';

class MedicacionRepositoryImpl implements MedicacionRepository {
  final SupabaseClient supabase;

  MedicacionRepositoryImpl({required this.supabase});

  @override
  Future<int> obtenerIdMedicamentoF1(int idTratamientoPaciente) async {
    final data =
        await supabase
            .from('medicacion_paciente_f1')
            .select('id_medicamento')
            .eq('id_tratamiento_paciente', idTratamientoPaciente)
            .maybeSingle();

    if (data == null || data['id_medicamento'] == null) {
      throw Exception('No se encontró medicación F1 para el tratamiento.');
    }

    return data['id_medicamento'] as int;
  }

  @override
  Future<int> obtenerIdMedicamentoF2(int idTratamientoPaciente) async {
    final data =
        await supabase
            .from('medicacion_paciente_f2')
            .select('id_medicamento')
            .eq('id_tratamiento_paciente', idTratamientoPaciente)
            .maybeSingle();

    if (data == null || data['id_medicamento'] == null) {
      throw Exception('No se encontró medicación F2 para el tratamiento.');
    }

    return data['id_medicamento'] as int;
  }

  @override
  Future<String> obtenerNombreMedicamento(int idMedicamento) async {
    final data =
        await supabase
            .from('medicamento')
            .select('nombre')
            .eq('id', idMedicamento)
            .maybeSingle();

    if (data == null || data['nombre'] == null) {
      throw Exception('No se encontró el nombre del medicamento.');
    }

    return data['nombre'] as String;
  }
}
