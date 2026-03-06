import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IniciarSesionUseCase {
  final SupabaseClient supabase;

  IniciarSesionUseCase({required this.supabase, dynamic storage});

  Future<void> call({required String email, required String password}) async {
    // Limpiar sesión local sin red para evitar que supabase intente refrescar
    // un token antiguo antes de hacer el sign-in, lo que puede colgar.
    debugPrint('🔑 [UseCase] Limpiando sesión local previa...');
    await supabase.auth.signOut(scope: SignOutScope.local);

    debugPrint('🔑 [UseCase] Llamando supabase.auth.signInWithPassword...');
    final response = await supabase.auth
        .signInWithPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception(
            'La conexión tardó demasiado. Verifica tu red e intenta de nuevo.',
          ),
        );
    debugPrint('🔑 [UseCase] Completado. User: ${response.user?.id}');

    final user = response.user;
    if (user == null || user.emailConfirmedAt == null) {
      debugPrint('❌ [UseCase] emailConfirmedAt=${user?.emailConfirmedAt}');
      throw Exception('Debes confirmar tu correo electrónico para continuar.');
    }
  }
}
