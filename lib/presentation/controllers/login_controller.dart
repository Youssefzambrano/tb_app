import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/iniciar_sesion_usecase.dart';
import '../../data/models/usuario_model.dart';
import '../../routes/app_routes.dart';
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Iniciando sesión...'),
    );

    try {
      debugPrint('🔐 [1] Llamando signInWithPassword...');
      await iniciarSesionUseCase(email: email, password: password);
      debugPrint('✅ [2] Auth exitoso. Consultando tabla usuario...');

      final data =
          await Supabase.instance.client
              .from('usuario')
              .select()
              .eq('correo_electronico', email)
              .single();
      debugPrint('✅ [3] Usuario encontrado en BD: $data');

      final usuario = UsuarioModel.fromMap(data);
      debugPrint('✅ [4] UsuarioModel creado: ID=${usuario.id}');

      if (usuario.id == null) {
        throw Exception('No se pudo obtener el ID del usuario.');
      }

      await SessionController().inicializarUsuarioActual(usuario);
      debugPrint('✅ [5] Sesión inicializada. Navegando...');

      if (!context.mounted) {
        debugPrint('⚠️ [6] context no montado, no se navega');
        return;
      }
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, AppRoutes.inicio);
      debugPrint('✅ [7] Navegación completada');
    } on AuthException catch (e) {
      debugPrint('❌ [AUTH ERROR] ${e.message} (statusCode: ${e.statusCode})');
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auth error: ${e.message}')));
    } catch (e, stack) {
      debugPrint('❌ [ERROR INESPERADO] $e');
      debugPrint('📋 Stack: $stack');
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
