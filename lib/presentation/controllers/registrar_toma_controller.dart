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
  final RegistrarTomaUseCase registrarTomaUseCase = RegistrarTomaUseCase(
    DosisRepositoryImpl(supabase: Supabase.instance.client),
  );

  Future<void> registrarTomaDesdeSesion({required BuildContext context}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Registrando toma...'),
    );

    try {
      final idUsuario = SessionController().idUsuario;
      if (idUsuario == null) throw Exception('Usuario no autenticado');

      final supabase = Supabase.instance.client;

      // 1. Obtener tratamiento activo
      final tratamientoResponse = await supabase
          .from('tratamiento_paciente')
          .select('id, fase1_intensiva_activa, fase2_continuacion_activa, dosis_pendientes')
          .eq('id_paciente', idUsuario)
          .eq('estado', 'En curso')
          .single();

      final int idTratamiento = tratamientoResponse['id'];
      final bool fase1Activa = tratamientoResponse['fase1_intensiva_activa'];
      final int dosisPendientes = tratamientoResponse['dosis_pendientes'];

      // 2. Verificar si ya se tomó la dosis hoy
      final now = DateTime.now();
      final inicioDia = DateTime(now.year, now.month, now.day);
      final finDia = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final dosisHoy = await supabase
          .from('dosis')
          .select('id')
          .eq('id_tratamiento_paciente', idTratamiento)
          .gte('fecha_hora_toma', inicioDia.toIso8601String())
          .lte('fecha_hora_toma', finDia.toIso8601String());

      if (dosisHoy.isNotEmpty) {
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya registraste la dosis de hoy. Solo se permite una dosis por día.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 3. Obtener id_medicamento real desde la tabla de medicación
      final tablaMedicacion =
          fase1Activa ? 'medicacion_paciente_f1' : 'medicacion_paciente_f2';
      final medResponse = await supabase
          .from(tablaMedicacion)
          .select('id_medicamento')
          .eq('id_tratamiento_paciente', idTratamiento)
          .single();
      final int idMedicamento = medResponse['id_medicamento'];

      // 4. Registrar la dosis
      await registrarTomaUseCase(
        idTratamientoPaciente: idTratamiento,
        idMedicamento: idMedicamento,
        fechaHoraToma: DateTime.now(),
        estado: 'Tomada',
      );

      // 5. Actualizar dosis_pendientes
      final nuevaDosisPendiente = dosisPendientes - 1;
      await supabase
          .from('tratamiento_paciente')
          .update({'dosis_pendientes': nuevaDosisPendiente})
          .eq('id', idTratamiento);

      // 6. Contar total de dosis tomadas en este tratamiento
      final countResponse = await supabase
          .from('dosis')
          .select('id')
          .eq('id_tratamiento_paciente', idTratamiento);
      final int totalDosisTomadas = countResponse.length;

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo de carga

      // 7. Evaluar transición de fase o finalización del tratamiento
      if (fase1Activa && totalDosisTomadas >= 56) {
        // Transición a fase de continuación
        await supabase
            .from('tratamiento_paciente')
            .update({
              'fase1_intensiva_activa': false,
              'fase2_continuacion_activa': true,
              'fecha_inicio_fase2': DateTime.now().toIso8601String(),
            })
            .eq('id', idTratamiento);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const FaseIntensivaTerminadaPantalla(),
            ),
          );
        }
      } else if (nuevaDosisPendiente <= 0) {
        // Tratamiento completado
        await supabase
            .from('tratamiento_paciente')
            .update({'estado': 'Completado'})
            .eq('id', idTratamiento);

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
