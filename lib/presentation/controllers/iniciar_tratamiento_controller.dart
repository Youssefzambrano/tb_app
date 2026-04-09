import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/iniciar_tratamiento_usecase.dart';
import '../../data/repositories_impl/tratamiento_repository_impl.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';

class IniciarTratamientoController {
  final IniciarTratamientoUseCase iniciarTratamientoUseCase;

  IniciarTratamientoController({
    IniciarTratamientoUseCase? iniciarTratamientoUseCase,
  }) : iniciarTratamientoUseCase =
           iniciarTratamientoUseCase ??
           IniciarTratamientoUseCase(
             TratamientoRepositoryImpl(supabase: Supabase.instance.client),
           );

  Future<void> iniciarTratamientoYRedirigir({
    required BuildContext context,
    required int idPaciente,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const DialogoCargando(mensaje: 'Iniciando tratamiento...'),
    );

    try {
      await iniciarTratamientoUseCase(idPaciente: idPaciente);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, AppRoutes.inicio);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      debugPrint('❌ Error al iniciar tratamiento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar tratamiento: $e')),
      );
    }
  }
}
