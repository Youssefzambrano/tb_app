import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/iniciar_tratamiento_usecase.dart';
import '../../data/repositories_impl/tratamiento_repository_impl.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';

class IniciarTratamientoController {
  final iniciarTratamientoUseCase = IniciarTratamientoUseCase(
    TratamientoRepositoryImpl(supabase: Supabase.instance.client),
  );

  Future<void> iniciarTratamientoDesdeSesion(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el usuario actual.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const DialogoCargando(mensaje: 'Iniciando tratamiento...'),
    );

    try {
      final response =
          await Supabase.instance.client
              .from('usuario')
              .select('id')
              .eq('correo_electronico', user.email!) // validado arriba
              .single();

      final int idUsuario = response['id'];

      await iniciarTratamientoUseCase(idPaciente: idUsuario);

      Navigator.of(context).pop(); // cerrar el diálogo
      Navigator.pushReplacementNamed(context, AppRoutes.inicio);
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint('❌ Error al iniciar tratamiento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar tratamiento: $e')),
      );
    }
  }
}
