import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// domain
import '../../domain/usecases/iniciar_sesion_usecase.dart';

// data
import '../../data/models/usuario_model.dart';

// presentation
import 'session_controller.dart';

// widgets
import '../../widgets/dialogo_cargando.dart';

class LoginController {
  final IniciarSesionUseCase iniciarSesionUseCase;
  final SupabaseClient supabase;
  final SessionController sessionController;

  LoginController({
    required this.iniciarSesionUseCase,
    required this.supabase,
    required this.sessionController,
  });

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

<<<<<<< HEAD
      final data =
          await supabase
              .from('usuario')
              .select()
              .eq('correo_electronico', email)
              .single();
=======
      final data = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('correo_electronico', emailNormalizado)
          .single();
>>>>>>> 0e1fb6b9a7ce1f37fd284421673a3b07413cdf24

      final usuario = UsuarioModel.fromMap(data);

      await sessionController.inicializarUsuarioActual(usuario);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      final rutaInicio = sessionController.rutaInicioPorRol;
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
