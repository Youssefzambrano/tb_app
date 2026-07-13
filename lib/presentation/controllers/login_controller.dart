import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/iniciar_sesion_usecase.dart';
import '../../data/models/usuario_model.dart';
import '../../widgets/dialogo_cargando.dart';
import 'session_controller.dart';

class LoginController {
  final IniciarSesionUseCase iniciarSesionUseCase;

  LoginController()
    : iniciarSesionUseCase = IniciarSesionUseCase(
        supabase: Supabase.instance.client,
      );

  Future<void> iniciarSesion({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Iniciando sesion...'),
    );

    try {
      await iniciarSesionUseCase(email: emailNormalizado, password: password);

      final data = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('correo_electronico', emailNormalizado)
          .single();

      final usuario = UsuarioModel.fromMap(data);

      await SessionController().inicializarUsuarioActual(usuario);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      final rutaInicio = SessionController().rutaInicioPorRol;
      Navigator.pushReplacementNamed(context, rutaInicio);
    } on AuthException {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contrasena incorrectos')),
      );
    } catch (e, stack) {
      debugPrint('❌ [LOGIN ERROR] $e');
      debugPrint('📋 $stack');
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
