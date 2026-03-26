import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/enfermero_resumen_paciente.dart';
import '../../domain/entities/sintoma.dart';
import '../../domain/repositories/enfermero_dashboard_repository.dart';
import '../models/enfermero_resumen_paciente_model.dart';
import '../models/sintoma_model.dart';

class EnfermeroDashboardRepositoryImpl implements EnfermeroDashboardRepository {
  final SupabaseClient supabase;

  EnfermeroDashboardRepositoryImpl({required this.supabase});

  @override
  Future<List<EnfermeroResumenPaciente>> obtenerResumenPacientesAsignados(
    int idEnfermero,
  ) async {
    final asignaciones = await supabase
        .from('paciente_enfermero')
        .select('id_paciente')
        .eq('id_enfermero', idEnfermero);

    final idsPacientes = (asignaciones as List)
        .map((e) => e['id_paciente'] as int)
        .toSet()
        .toList();

    if (idsPacientes.isEmpty) return [];

    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = inicioDia
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final resumenes = <EnfermeroResumenPaciente>[];

    for (final idPaciente in idsPacientes) {
      final usuario = await supabase
          .from('usuario')
          .select('nombre, correo_electronico')
          .eq('id', idPaciente)
          .single();

      final tratamiento = await supabase
          .from('tratamiento_paciente')
          .select(
            'id, estado, total_dosis, fase1_intensiva_activa, fase2_continuacion_activa',
          )
          .eq('id_paciente', idPaciente)
          .eq('estado', 'En curso')
          .maybeSingle();

      int dosisTomadas = 0;
      int dosisTotales = 0;
      bool dosisHoyTomada = false;
      bool reportoSintomasHoy = false;
      String faseActual = 'Sin fase';
      String estadoTratamiento = 'Sin tratamiento';
      int? idTratamiento;

      if (tratamiento != null) {
        idTratamiento = tratamiento['id'] as int;
        estadoTratamiento = (tratamiento['estado'] as String?) ?? 'En curso';
        dosisTotales = (tratamiento['total_dosis'] as int?) ?? 0;

        final fase1 = (tratamiento['fase1_intensiva_activa'] as bool?) ?? false;
        final fase2 =
            (tratamiento['fase2_continuacion_activa'] as bool?) ?? false;
        faseActual = _obtenerFase(fase1Activa: fase1, fase2Activa: fase2);

        final dosis = await supabase
            .from('dosis')
            .select('id')
            .eq('id_tratamiento_paciente', idTratamiento);
        dosisTomadas = (dosis as List).length;

        final dosisHoy = await supabase
            .from('dosis')
            .select('id')
            .eq('id_tratamiento_paciente', idTratamiento)
            .gte('fecha_hora_toma', inicioDia.toIso8601String())
            .lte('fecha_hora_toma', finDia.toIso8601String())
            .maybeSingle();
        dosisHoyTomada = dosisHoy != null;

        final seguimientosHoy = await supabase
            .from('seguimiento_paciente')
            .select('id')
            .eq('id_paciente', idPaciente)
            .eq('id_tratamiento_paciente', idTratamiento)
            .eq('fecha_reporte', inicioDia.toIso8601String().split('T').first);

        final idsSeguimiento = (seguimientosHoy as List)
            .map((s) => s['id'] as int)
            .toList();

        if (idsSeguimiento.isNotEmpty) {
          final sintomas = await supabase
              .from('sintomas_paciente')
              .select('id')
              .inFilter('id_seguimiento', idsSeguimiento)
              .limit(1);
          reportoSintomasHoy = (sintomas as List).isNotEmpty;
        }
      }

      final prioridad = _calcularPrioridad(
        reportoSintomasHoy: reportoSintomasHoy,
        dosisHoyTomada: dosisHoyTomada,
      );

      resumenes.add(
        EnfermeroResumenPacienteModel(
          idPaciente: idPaciente,
          idTratamiento: idTratamiento,
          nombrePaciente: (usuario['nombre'] as String?) ?? 'Paciente',
          correoPaciente: (usuario['correo_electronico'] as String?) ?? '',
          faseActual: faseActual,
          estadoTratamiento: estadoTratamiento,
          dosisTomadas: dosisTomadas,
          dosisTotales: dosisTotales,
          dosisHoyTomada: dosisHoyTomada,
          reportoSintomasHoy: reportoSintomasHoy,
          prioridadClinica: prioridad,
        ),
      );
    }

    return resumenes;
  }

  @override
  Future<void> validarTomaPaciente({
    required int idPaciente,
    required int idTratamientoPaciente,
    required String estado,
  }) async {
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = inicioDia
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final dosisHoy = await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamientoPaciente)
        .gte('fecha_hora_toma', inicioDia.toIso8601String())
        .lte('fecha_hora_toma', finDia.toIso8601String())
        .order('fecha_hora_toma', ascending: false)
        .maybeSingle();

    if (dosisHoy != null) {
      await supabase.from('dosis').update({'estado': estado}).eq(
        'id',
        dosisHoy['id'],
      );
      return;
    }

    final tratamiento = await supabase
        .from('tratamiento_paciente')
        .select('fase1_intensiva_activa')
        .eq('id', idTratamientoPaciente)
        .eq('id_paciente', idPaciente)
        .single();

    final bool fase1Activa = (tratamiento['fase1_intensiva_activa'] as bool?) ?? true;
    final tablaMedicacion = fase1Activa
        ? 'medicacion_paciente_f1'
        : 'medicacion_paciente_f2';

    final medicacion = await supabase
        .from(tablaMedicacion)
        .select('id_medicamento')
        .eq('id_tratamiento_paciente', idTratamientoPaciente)
        .maybeSingle();

    if (medicacion == null || medicacion['id_medicamento'] == null) {
      throw Exception('No se encontro medicacion para registrar la toma.');
    }

    await supabase.from('dosis').insert({
      'id_tratamiento_paciente': idTratamientoPaciente,
      'id_medicamento': medicacion['id_medicamento'],
      'fecha_hora_toma': now.toIso8601String(),
      'estado': estado,
    });
  }

  @override
  Future<List<Sintoma>> obtenerCatalogoSintomas() async {
    final data = await supabase.from('sintoma').select('id, nombre').order(
      'nombre',
    );
    return (data as List)
        .map((item) => SintomaModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> registrarSeguimientoClinico({
    required int idPaciente,
    required int idTratamientoPaciente,
    required int dosisOmitidas,
    required List<int> idsSintomas,
  }) async {
    final seguimiento = await supabase
        .from('seguimiento_paciente')
        .insert({
          'id_paciente': idPaciente,
          'id_tratamiento_paciente': idTratamientoPaciente,
          'fecha_reporte': DateTime.now().toIso8601String(),
          'dosis_omitidas': dosisOmitidas,
        })
        .select('id')
        .single();

    final int idSeguimiento = seguimiento['id'] as int;

    if (idsSintomas.isEmpty) return;

    final inserts = idsSintomas
        .map(
          (idSintoma) => {
            'id_seguimiento': idSeguimiento,
            'id_sintoma': idSintoma,
            'fecha_registro': DateTime.now().toIso8601String(),
          },
        )
        .toList();

    await supabase.from('sintomas_paciente').insert(inserts);
  }

  String _obtenerFase({
    required bool fase1Activa,
    required bool fase2Activa,
  }) {
    if (fase1Activa) return 'Intensiva';
    if (fase2Activa) return 'Continuacion';
    return 'Sin fase';
  }

  int _calcularPrioridad({
    required bool reportoSintomasHoy,
    required bool dosisHoyTomada,
  }) {
    if (reportoSintomasHoy && !dosisHoyTomada) return 4;
    if (reportoSintomasHoy) return 3;
    if (!dosisHoyTomada) return 2;
    return 1;
  }
}
