import '../entities/tratamiento_paciente.dart';
import '../entities/medicacion_paciente_f1.dart';
import '../entities/medicacion_paciente_f2.dart';
import '../entities/seguimiento_paciente.dart';
import '../repositories/tratamiento_repository.dart';

class IniciarTratamientoUseCase {
  final TratamientoRepository repository;

  IniciarTratamientoUseCase(this.repository);

  Future<void> call({required int idPaciente, double? pesoPaciente}) async {
    // 1. Crear tratamiento base
    final tratamiento = TratamientoPaciente(
      id: null, // ID se autogenera
      idPaciente: idPaciente,
      nombre: 'Tratamiento Estándar',
      descripcion: 'Fase intensiva y de continuación para TB',
      fechaInicio: DateTime.now(),
      fechaFinalizacion: null,
      duracionTotal: 168,
      estado: 'En curso',
      pesoPaciente: pesoPaciente,
      totalDosis: 168,
      dosisPendientes: 168,
      fase1IntensivaActiva: true,
      fase2ContinuacionActiva: false,
    );

    // 2. Medicación fase intensiva
    final medicacionF1 = MedicacionPacienteF1(
      id: null,
      idTratamientoPaciente: 0, // Se actualizará internamente
      idMedicamento: 1,
      dosisDiaria: 1.0,
      frecuencia: 1,
      duracion: 56,
    );

    // 3. Medicación fase de continuación
    final medicacionF2 = MedicacionPacienteF2(
      id: null,
      idTratamientoPaciente: 0, // Se actualizará internamente
      idMedicamento: 2,
      dosisDiaria: 1.0,
      frecuencia: 1,
      duracion: 112,
    );

    // 4. Seguimiento inicial
    final seguimiento = SeguimientoPaciente(
      id: null,
      idPaciente: idPaciente,
      idTratamientoPaciente: 0, // Se actualizará internamente
      fechaReporte: DateTime.now(),
      dosisOmitidas: 0,
    );

    // 5. Ejecutar todo en el repositorio
    await repository.iniciarTratamientoCompleto(
      tratamiento: tratamiento,
      medicacionF1: medicacionF1,
      medicacionF2: medicacionF2,
      seguimiento: seguimiento,
    );
  }
}
