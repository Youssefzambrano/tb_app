import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';
import '../features/tratamiento/pages/fase_intensiva_terminada_pantalla.dart';
import '../features/tratamiento/pages/tratamiento_terminado_pantalla.dart';
import 'session_controller.dart';

class RegistrarTomaController {
  Future<void> registrarTomaDesdeSesion({
    required BuildContext context,
    File? fotoFile,
  }) async {
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
          .select(
              'id, fase1_intensiva_activa, fase2_continuacion_activa, dosis_pendientes')
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
              content: Text(
                  'Ya registraste la dosis de hoy. Solo se permite una dosis por día.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 3. Obtener id_medicamento real
      final tablaMedicacion =
          fase1Activa ? 'medicacion_paciente_f1' : 'medicacion_paciente_f2';
      final medResponse = await supabase
          .from(tablaMedicacion)
          .select('id_medicamento')
          .eq('id_tratamiento_paciente', idTratamiento)
          .single();
      final int idMedicamento = medResponse['id_medicamento'];

      // 4. Subir foto a Supabase Storage
      String? fotoUrl;
      if (fotoFile != null) {
        final fileName =
            'paciente_${idUsuario}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storagePath = 'dosis/$fileName';
        await supabase.storage.from('dosis-fotos').uploadBinary(
              storagePath,
              await fotoFile.readAsBytes(),
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        fotoUrl =
            supabase.storage.from('dosis-fotos').getPublicUrl(storagePath);
      }

      // 5. Registrar la dosis
      await supabase.from('dosis').insert({
        'id_tratamiento_paciente': idTratamiento,
        'id_medicamento': idMedicamento,
        'fecha_hora_toma': DateTime.now().toIso8601String(),
        'estado': 'Tomada',
        if (fotoUrl != null) 'foto_url': fotoUrl,
      });

      // 6. Actualizar dosis_pendientes
      final nuevaDosisPendiente = dosisPendientes - 1;
      await supabase
          .from('tratamiento_paciente')
          .update({'dosis_pendientes': nuevaDosisPendiente})
          .eq('id', idTratamiento);

      // 7. Contar total de dosis tomadas
      final countResponse = await supabase
          .from('dosis')
          .select('id')
          .eq('id_tratamiento_paciente', idTratamiento);
      final int totalDosisTomadas = countResponse.length;

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo

      // 8. Evaluar transición de fase o fin de tratamiento
      if (fase1Activa && totalDosisTomadas >= 56) {
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
