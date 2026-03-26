import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/cerrar_sesion_usecase.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';

class SessionController {
  // Singleton
  static final SessionController _instance = SessionController._internal();
  factory SessionController() => _instance;
  SessionController._internal();

  final CerrarSesionUseCase cerrarSesionUseCase = CerrarSesionUseCase(
    supabase: Supabase.instance.client,
    storage: const FlutterSecureStorage(),
  );

  /// Usuario autenticado actual
  Usuario? usuarioActual;

  /// Inicializa el usuario en memoria después del login
  Future<void> inicializarUsuarioActual(Usuario usuario) async {
    usuarioActual = usuario;
  }

  /// Limpia los datos de sesión
  Future<void> cerrarSesionYRedirigir(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Cerrando sesión...'),
    );

    try {
      await cerrarSesionUseCase();
      usuarioActual = null; // Limpia el usuario actual
      Navigator.of(context).pop(); // Cierra el diálogo
      Navigator.pushNamedAndRemoveUntil(context, '/bienvenida', (_) => false);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  /// Getters de conveniencia para usar en la UI
  int? get idUsuario => usuarioActual?.id;
  String get nombreUsuario => usuarioActual?.nombre ?? 'Usuario';
  String get correoUsuario => usuarioActual?.correoElectronico ?? '';
  String get nivelAcceso => usuarioActual?.nivelAcceso ?? 'Basico';
  bool get esEnfermero => nivelAcceso.toLowerCase() == 'enfermero';
  String get rutaInicioPorRol => esEnfermero ? AppRoutes.inicioEnfermero : AppRoutes.inicio;
}
