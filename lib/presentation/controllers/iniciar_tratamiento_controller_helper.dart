import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/iniciar_tratamiento_usecase.dart';
import '../../data/repositories_impl/tratamiento_repository_impl.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';

typedef ObtenerIdUsuarioPorCorreo =
    Future<int> Function(SupabaseClient supabase, String correo);

Future<int> _obtenerIdUsuarioPorCorreoDefault(
  SupabaseClient supabase,
  String correo,
) async {
  final response =
      await supabase
          .from('usuario')
          .select('id')
          .eq('correo_electronico', correo)
          .single();

  return response['id'] as int;
}

class IniciarTratamientoController {
  final SupabaseClient supabase;
  final IniciarTratamientoUseCase iniciarTratamientoUseCase;
  final ObtenerIdUsuarioPorCorreo obtenerIdUsuarioPorCorreo;

  IniciarTratamientoController({
    SupabaseClient? supabase,
    IniciarTratamientoUseCase? iniciarTratamientoUseCase,
    ObtenerIdUsuarioPorCorreo? obtenerIdUsuarioPorCorreo,
  }) : supabase = supabase ?? Supabase.instance.client,
       iniciarTratamientoUseCase =
           iniciarTratamientoUseCase ??
           IniciarTratamientoUseCase(
             TratamientoRepositoryImpl(
               supabase: supabase ?? Supabase.instance.client,
             ),
           ),
       obtenerIdUsuarioPorCorreo =
           obtenerIdUsuarioPorCorreo ?? _obtenerIdUsuarioPorCorreoDefault;

  Future<void> iniciarTratamientoDesdeSesion(BuildContext context) async {
    final user = supabase.auth.currentUser;

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
      final int idUsuario = await obtenerIdUsuarioPorCorreo(
        supabase,
        user.email!,
      );

      await iniciarTratamientoUseCase(idPaciente: idUsuario);

      Navigator.of(context).pop();
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
