import '../entities/tratamiento_paciente.dart';
import '../entities/medicacion_paciente_f1.dart';
import '../entities/medicacion_paciente_f2.dart';
import '../entities/seguimiento_paciente.dart';

abstract class TratamientoRepository {
  Future<int> insertarTratamiento(TratamientoPaciente tratamiento);
  Future<void> insertarMedicacionF1(MedicacionPacienteF1 medicacion);
  Future<void> insertarMedicacionF2(MedicacionPacienteF2 medicacion);
  Future<void> insertarSeguimiento(SeguimientoPaciente seguimiento);

  Future<void> iniciarTratamientoCompleto({
    required TratamientoPaciente tratamiento,
    required MedicacionPacienteF1 medicacionF1,
    required MedicacionPacienteF2 medicacionF2,
    required SeguimientoPaciente seguimiento,
  });
}
