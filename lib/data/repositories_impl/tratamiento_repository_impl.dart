import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tratamiento_paciente.dart';
import '../../domain/entities/medicacion_paciente_f1.dart';
import '../../domain/entities/medicacion_paciente_f2.dart';
import '../../domain/entities/seguimiento_paciente.dart';
import '../../domain/repositories/tratamiento_repository.dart';
import '../models/tratamiento_paciente_model.dart';
import '../models/medicacion_paciente_f1_model.dart';
import '../models/medicacion_paciente_f2_model.dart';
import '../models/seguimiento_paciente_model.dart';

class TratamientoRepositoryImpl implements TratamientoRepository {
  final SupabaseClient supabase;

  TratamientoRepositoryImpl({required this.supabase});

  @override
  Future<int> insertarTratamiento(TratamientoPaciente tratamiento) async {
    final model = TratamientoPacienteModel.fromEntity(tratamiento);
    final response =
        await supabase
            .from('tratamiento_paciente')
            .insert(model.toMap())
            .select()
            .single();
    return response['id'] as int;
  }

  @override
  Future<void> insertarMedicacionF1(MedicacionPacienteF1 medicacion) async {
    final model = MedicacionPacienteF1Model(
      idTratamientoPaciente: medicacion.idTratamientoPaciente,
      idMedicamento: medicacion.idMedicamento,
      dosisDiaria: medicacion.dosisDiaria,
      frecuencia: medicacion.frecuencia,
      duracion: medicacion.duracion,
    );
    await supabase.from('medicacion_paciente_f1').insert(model.toMap());
  }

  @override
  Future<void> insertarMedicacionF2(MedicacionPacienteF2 medicacion) async {
    final model = MedicacionPacienteF2Model(
      idTratamientoPaciente: medicacion.idTratamientoPaciente,
      idMedicamento: medicacion.idMedicamento,
      dosisDiaria: medicacion.dosisDiaria,
      frecuencia: medicacion.frecuencia,
      duracion: medicacion.duracion,
    );
    await supabase.from('medicacion_paciente_f2').insert(model.toMap());
  }

  @override
  Future<void> insertarSeguimiento(SeguimientoPaciente seguimiento) async {
    final model = SeguimientoPacienteModel(
      idPaciente: seguimiento.idPaciente,
      idTratamientoPaciente: seguimiento.idTratamientoPaciente,
      dosisOmitidas: seguimiento.dosisOmitidas,
    );
    await supabase.from('seguimiento_paciente').insert(model.toMap());
  }

  @override
  Future<void> iniciarTratamientoCompleto({
    required TratamientoPaciente tratamiento,
    required MedicacionPacienteF1 medicacionF1,
    required MedicacionPacienteF2 medicacionF2,
    required SeguimientoPaciente seguimiento,
  }) async {
    final int idTratamiento = await insertarTratamiento(tratamiento);

    final medicacionF1Actualizada = medicacionF1.copyWith(
      idTratamientoPaciente: idTratamiento,
    );
    final medicacionF2Actualizada = medicacionF2.copyWith(
      idTratamientoPaciente: idTratamiento,
    );
    final seguimientoActualizado = seguimiento.copyWith(
      idTratamientoPaciente: idTratamiento,
    );

    await insertarMedicacionF1(medicacionF1Actualizada);
    await insertarMedicacionF2(medicacionF2Actualizada);
    await insertarSeguimiento(seguimientoActualizado);
  }
}
