import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/usecases/iniciar_sesion_usecase.dart';
import '../../data/repositories_impl/usuario_repository_impl.dart';
import '../../data/datasources/remote/supabase/auth_supabase_service.dart';
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
      builder: (_) => const DialogoCargando(mensaje: 'Iniciando sesion...'),
    );

    try {
      await iniciarSesionUseCase(email: email, password: password);

      final usuarioRepo = UsuarioRepositoryImpl(
        supabase: Supabase.instance.client,
        authService: AuthSupabaseService(),
      );

      final usuario = await usuarioRepo.iniciarSesion(email, password);

      if (usuario.id == null) {
        throw Exception('No se pudo obtener el ID del usuario.');
      }

      await SessionController().inicializarUsuarioActual(usuario);
      debugPrint(
        'Usuario cargado en sesion: ID=${usuario.id}, Nombre=${usuario.nombre}, Rol=${usuario.nivelAcceso}',
      );

      Navigator.of(context).pop();
      final rutaInicio = SessionController().rutaInicioPorRol;
      Navigator.pushReplacementNamed(context, rutaInicio);
    } on AuthException catch (e) {
      Navigator.of(context).pop();
      debugPrint('Auth error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contrasena incorrectos')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint('Error inesperado en login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrio un error. Intenta nuevamente.')),
      );
    }
  }
}
