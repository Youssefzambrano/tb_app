import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/paciente.dart';
import '../../domain/repositories/paciente_repository.dart';
import '../models/paciente_model.dart';

class PacienteRepositoryImpl implements PacienteRepository {
  final SupabaseClient supabase;

  PacienteRepositoryImpl({required this.supabase});

  @override
  Future<void> registrarPaciente(Paciente paciente) async {
    final pacienteModel = PacienteModel(
      id: paciente.id,
      fechaDiagnostico: paciente.fechaDiagnostico,
      tipoTuberculosis: paciente.tipoTuberculosis ?? 'Sensible',
      estadoTratamiento: paciente.estadoTratamiento ?? 'Activo',
      nombreContactoEmergencia: paciente.nombreContactoEmergencia,
      telefonoContactoEmergencia: paciente.telefonoContactoEmergencia,
    );

    await supabase.from('paciente').insert(pacienteModel.toMap());
  }

  @override
  Future<Paciente?> obtenerPacientePorId(int id) async {
    final data =
        await supabase.from('paciente').select().eq('id', id).maybeSingle();

    if (data == null) return null;
    return PacienteModel.fromMap(data);
  }

  @override
  Future<void> actualizarPaciente(Paciente paciente) async {
    final pacienteModel = paciente as PacienteModel;
    await supabase
        .from('paciente')
        .update(pacienteModel.toMap())
        .eq('id', paciente.id);
  }

  @override
  Future<void> eliminarPaciente(int id) async {
    await supabase.from('paciente').delete().eq('id', id);
  }
}
