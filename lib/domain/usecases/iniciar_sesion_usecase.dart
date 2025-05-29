import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IniciarSesionUseCase {
  final SupabaseClient supabase;
  final FlutterSecureStorage secureStorage;

  IniciarSesionUseCase({required this.supabase, FlutterSecureStorage? storage})
    : secureStorage = storage ?? const FlutterSecureStorage();

  Future<void> call({required String email, required String password}) async {
    // Iniciar sesión
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null || user.emailConfirmedAt == null) {
      throw Exception('Debes confirmar tu correo electrónico para continuar.');
    }

    // Guardar credenciales seguras
    await secureStorage.write(key: 'email', value: email);
    await secureStorage.write(key: 'password', value: password);
  }
}
