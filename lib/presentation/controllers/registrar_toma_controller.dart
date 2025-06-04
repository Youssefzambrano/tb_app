import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/registrar_toma_usecase.dart';
import '../../data/repositories_impl/dosis_repository_impl.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';
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

      if (idUsuario == null) {
        throw Exception('Usuario no autenticado');
      }

      final tratamientoResponse =
          await Supabase.instance.client
              .from('tratamiento_paciente')
              .select('id, fase1_intensiva_activa, dosis_pendientes')
              .eq('id_paciente', idUsuario)
              .eq('estado', 'En curso')
              .single();

      final int idTratamiento = tratamientoResponse['id'];
      final bool fase1Activa = tratamientoResponse['fase1_intensiva_activa'];
      final int dosisPendientes = tratamientoResponse['dosis_pendientes'];

      final int idMedicamento = fase1Activa ? 1 : 2;
      const String estado = 'Tomada';

      await registrarTomaUseCase(
        idTratamientoPaciente: idTratamiento,
        idMedicamento: idMedicamento,
        fechaHoraToma: DateTime.now(),
        estado: estado,
      );

      // Actualizar dosis pendientes
      final nuevaDosisPendiente = dosisPendientes - 1;
      await Supabase.instance.client
          .from('tratamiento_paciente')
          .update({'dosis_pendientes': nuevaDosisPendiente})
          .eq('id', idTratamiento);

      Navigator.pushReplacementNamed(context, AppRoutes.exitoToma);
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint('❌ Error al registrar toma: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar la toma: $e')));
    }
  }
}
