import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    final session = response.session;

    if (user == null && session == null) {
      throw Exception('No se pudo registrar. Verifica tus datos.');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Credenciales incorrectas.');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    final response = await _supabase.functions.invoke(
      'reset-password-temp',
      body: {'email': email},
    );
    if (response.status != 200) {
      final message =
          (response.data as Map<String, dynamic>?)?['error']?.toString() ??
              'No se pudo enviar la contraseña temporal.';
      throw Exception(message);
    }
  }
}
