import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/cerrar_sesion_usecase.dart';
import '../../widgets/dialogo_cargando.dart';

class SessionController {
  final CerrarSesionUseCase cerrarSesionUseCase;

  SessionController()
    : cerrarSesionUseCase = CerrarSesionUseCase(
        supabase: Supabase.instance.client,
        storage: const FlutterSecureStorage(),
      );

  Future<void> cerrarSesionYRedirigir(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCargando(mensaje: 'Cerrando sesión...'),
    );

    try {
      await cerrarSesionUseCase();
      Navigator.of(context).pop(); // Cerrar el dialogo de carga
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/bienvenida',
        (route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar el dialogo de carga si hay error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }
}
