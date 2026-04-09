import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/registrar_toma_usecase.dart';
import '../../data/repositories_impl/dosis_repository_impl.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';
import '../features/tratamiento/pages/fase_intensiva_terminada_pantalla.dart';
import '../features/tratamiento/pages/tratamiento_terminado_pantalla.dart';
import 'session_controller.dart';

class RegistrarTomaController {
  final RegistrarTomaUseCase registrarTomaUseCase;
  final SupabaseClient supabase;
  final SessionController sessionController;

  RegistrarTomaController({
    RegistrarTomaUseCase? registrarTomaUseCase,
    SupabaseClient? supabase,
    SessionController? sessionController,
  }) : supabase = supabase ?? Supabase.instance.client,
       sessionController = sessionController ?? SessionController(),
       registrarTomaUseCase =
           registrarTomaUseCase ??
           RegistrarTomaUseCase(
             DosisRepositoryImpl(
               supabase: supabase ?? Supabase.instance.client,
             ),
           );

  Future<Map<String, dynamic>> obtenerTratamientoEnCurso(int idUsuario) async {
    return await supabase
        .from('tratamiento_paciente')
        .select(
          'id, fase1_intensiva_activa, fase2_continuacion_activa, dosis_pendientes',
        )
        .eq('id_paciente', idUsuario)
        .eq('estado', 'En curso')
        .single();
  }

  Future<List<dynamic>> obtenerDosisDeHoy(int idTratamiento) async {
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento)
        .gte('fecha_hora_toma', inicioDia.toIso8601String())
        .lte('fecha_hora_toma', finDia.toIso8601String());
  }

  Future<int> obtenerMedicamentoId(bool fase1Activa, int idTratamiento) async {
    final tablaMedicacion =
        fase1Activa ? 'medicacion_paciente_f1' : 'medicacion_paciente_f2';

    final medResponse =
        await supabase
            .from(tablaMedicacion)
            .select('id_medicamento')
            .eq('id_tratamiento_paciente', idTratamiento)
            .single();

    return medResponse['id_medicamento'];
  }

  Future<void> actualizarDosisPendientes(
    int idTratamiento,
    int nuevaDosisPendiente,
  ) async {
    await supabase
        .from('tratamiento_paciente')
        .update({'dosis_pendientes': nuevaDosisPendiente})
        .eq('id', idTratamiento);
  }

  Future<int> obtenerTotalDosisTomadas(int idTratamiento) async {
    final countResponse = await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento);

    return countResponse.length;
  }

  Future<void> activarFase2(int idTratamiento) async {
    await supabase
        .from('tratamiento_paciente')
        .update({
          'fase1_intensiva_activa': false,
          'fase2_continuacion_activa': true,
          'fecha_inicio_fase2': DateTime.now().toIso8601String(),
        })
        .eq('id', idTratamiento);
  }

  Future<void> completarTratamiento(int idTratamiento) async {
    await supabase
        .from('tratamiento_paciente')
        .update({'estado': 'Completado'})
        .eq('id', idTratamiento);
  }

  Future<void> registrarTomaDesdeSesion({required BuildContext context}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Registrando toma...'),
    );

    try {
      final idUsuario = sessionController.idUsuario;
      if (idUsuario == null) throw Exception('Usuario no autenticado');

      final tratamientoResponse = await obtenerTratamientoEnCurso(idUsuario);

      final int idTratamiento = tratamientoResponse['id'];
      final bool fase1Activa = tratamientoResponse['fase1_intensiva_activa'];
      final int dosisPendientes = tratamientoResponse['dosis_pendientes'];

      final dosisHoy = await obtenerDosisDeHoy(idTratamiento);

      if (dosisHoy.isNotEmpty) {
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ya registraste la dosis de hoy. Solo se permite una dosis por día.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final int idMedicamento = await obtenerMedicamentoId(
        fase1Activa,
        idTratamiento,
      );

      await registrarTomaUseCase(
        idTratamientoPaciente: idTratamiento,
        idMedicamento: idMedicamento,
        fechaHoraToma: DateTime.now(),
        estado: 'Tomada',
      );

      final nuevaDosisPendiente = dosisPendientes - 1;
      await actualizarDosisPendientes(idTratamiento, nuevaDosisPendiente);

      final int totalDosisTomadas = await obtenerTotalDosisTomadas(
        idTratamiento,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (fase1Activa && totalDosisTomadas >= 56) {
        await activarFase2(idTratamiento);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const FaseIntensivaTerminadaPantalla(),
            ),
          );
        }
      } else if (nuevaDosisPendiente <= 0) {
        await completarTratamiento(idTratamiento);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const TratamientoTerminadoPantalla(),
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.exitoToma);
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      debugPrint('❌ Error al registrar toma: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la toma: $e')),
        );
      }
    }
  }
}
