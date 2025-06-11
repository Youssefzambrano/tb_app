import 'package:flutter/foundation.dart';
import '../../presentation/viewmodels/dashboard_resumen_paciente.dart';
import '../repositories/dosis_repository.dart';
import '../repositories/tratamiento_repository.dart';
import '../repositories/medicacion_repository.dart';

class ObtenerDashboardPacienteUseCase {
  final DosisRepository dosisRepo;
  final TratamientoRepository tratamientoRepo;
  final MedicacionRepository medicacionRepo;

  ObtenerDashboardPacienteUseCase({
    required this.dosisRepo,
    required this.tratamientoRepo,
    required this.medicacionRepo,
  });

  Future<DashboardPacienteResumen> call(int idPaciente) async {
    // 1. Obtener tratamiento activo
    final tratamiento = await tratamientoRepo.obtenerTratamientoActivo(
      idPaciente,
    );

    debugPrint('✅ Tratamiento encontrado: ${tratamiento.id}');

    final bool fase1Activa = tratamiento.fase1IntensivaActiva;
    final bool fase2Activa = tratamiento.fase2ContinuacionActiva;
    final int dosisTotales = tratamiento.totalDosis;

    // 2. Obtener cantidad de dosis tomadas
    final dosisTomadas = await dosisRepo.contarDosisPorUsuario(idPaciente);
    final porcentaje =
        dosisTotales > 0 ? (dosisTomadas / dosisTotales) * 100 : 0.0;

    // 3. Obtener última dosis y verificar si la dosis de hoy fue tomada
    final ultimaDosis = await dosisRepo.obtenerUltimaDosis(idPaciente);
    final dosisDeHoyTomada = await dosisRepo.existeDosisHoy(idPaciente);

    // 4. Determinar fase actual y obtener medicamento
    String faseActual = '';
    String medicamentoNombre = '';
    DateTime? fechaInicio;
    DateTime? fechaFin;
    final idTratamiento = tratamiento.id;

    if (fase1Activa) {
      faseActual = 'Intensiva';
      fechaInicio = tratamiento.fechaInicioFase1;
      fechaFin = fechaInicio?.add(const Duration(days: 56));

      final idMedicamento = await medicacionRepo.obtenerIdMedicamentoF1(
        idTratamiento!,
      );
      medicamentoNombre = await medicacionRepo.obtenerNombreMedicamento(
        idMedicamento,
      );
    } else if (fase2Activa) {
      faseActual = 'Continuación';
      fechaInicio = tratamiento.fechaInicioFase2;
      fechaFin = fechaInicio?.add(const Duration(days: 112));

      final idMedicamento = await medicacionRepo.obtenerIdMedicamentoF2(
        idTratamiento!,
      );
      medicamentoNombre = await medicacionRepo.obtenerNombreMedicamento(
        idMedicamento,
      );
    }

    // 5. Calcular días completados y restantes
    final now = DateTime.now();
    final diasCompletados =
        fechaInicio != null
            ? now.difference(fechaInicio).inDays.clamp(0, 999)
            : 0;
    final diasRestantes =
        fechaFin != null ? fechaFin.difference(now).inDays.clamp(0, 999) : 0;

    // 6. Devolver resumen completo
    return DashboardPacienteResumen(
      dosisTomadas: dosisTomadas,
      dosisTotales: dosisTotales,
      porcentaje: porcentaje,
      faseActual: faseActual,
      ultimaDosis: ultimaDosis?.fechaHoraToma,
      dosisDeHoyTomada: dosisDeHoyTomada,
      medicamentoActual: medicamentoNombre,
      diasCompletados: diasCompletados,
      diasRestantes: diasRestantes,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }
}
