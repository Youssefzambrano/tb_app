import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/usecases/iniciar_sesion_usecase.dart';
import '../../data/repositories_impl/usuario_repository_impl.dart';
import '../../data/datasources/remote/supabase/auth_supabase_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dialogo_cargando.dart';
import 'session_controller.dart';

class LoginController {
  final IniciarSesionUseCase iniciarSesionUseCase;

  LoginController()
    : iniciarSesionUseCase = IniciarSesionUseCase(
        supabase: Supabase.instance.client,
        storage: const FlutterSecureStorage(),
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
      await iniciarSesionUseCase(email: email, password: password);

      final usuarioRepo = UsuarioRepositoryImpl(
        supabase: Supabase.instance.client,
        authService: AuthSupabaseService(),
      );

      final usuario = await usuarioRepo.iniciarSesion(email, password);
      await SessionController().inicializarUsuarioActual(usuario);

      Navigator.of(context).pop(); // Cierra el diálogo
      Navigator.pushReplacementNamed(context, AppRoutes.inicio);
    } on AuthException catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo si falla
      debugPrint('❌ Auth error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo si falla
      debugPrint('❌ Otro error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error. Intenta nuevamente.')),
      );
    }
  }
}
