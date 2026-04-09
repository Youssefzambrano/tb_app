import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/cerrar_sesion_usecase.dart';
import '../../widgets/dialogo_cargando.dart';
import '../../routes/app_routes.dart';

class SessionController {
  static SessionController? _instance;

  factory SessionController({CerrarSesionUseCase? cerrarSesionUseCase}) {
    _instance ??= SessionController._internal(cerrarSesionUseCase);
    return _instance!;
  }

  SessionController._internal(CerrarSesionUseCase? cerrarSesionUseCase)
    : cerrarSesionUseCase =
          cerrarSesionUseCase ??
          CerrarSesionUseCase(
            supabase: Supabase.instance.client,
            storage: const FlutterSecureStorage(),
          );

  final CerrarSesionUseCase cerrarSesionUseCase;

  Usuario? usuarioActual;

  Future<void> inicializarUsuarioActual(Usuario usuario) async {
    usuarioActual = usuario;
  }

  Future<void> cerrarSesionYRedirigir(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Cerrando sesión...'),
    );

    try {
      await cerrarSesionUseCase();
      usuarioActual = null;
      Navigator.of(context).pop();
      Navigator.pushNamedAndRemoveUntil(context, '/bienvenida', (_) => false);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  int? get idUsuario => usuarioActual?.id;
  String get nombreUsuario => usuarioActual?.nombre ?? 'Usuario';
  String get correoUsuario => usuarioActual?.correoElectronico ?? '';
  String get nivelAcceso => usuarioActual?.nivelAcceso ?? 'Basico';
  bool get esEnfermero => nivelAcceso.toLowerCase() == 'enfermero';
  String get rutaInicioPorRol =>
      esEnfermero ? AppRoutes.inicioEnfermero : AppRoutes.inicio;

  static void resetForTest() {
    _instance = null;
  }
}
