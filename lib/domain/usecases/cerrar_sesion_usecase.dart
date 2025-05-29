import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CerrarSesionUseCase {
  final SupabaseClient supabase;
  final FlutterSecureStorage secureStorage;

  CerrarSesionUseCase({required this.supabase, FlutterSecureStorage? storage})
    : secureStorage = storage ?? const FlutterSecureStorage();

  Future<void> call() async {
    // Cierra sesión en Supabase
    await supabase.auth.signOut();

    // Elimina las credenciales almacenadas
    await secureStorage.delete(key: 'email');
    await secureStorage.delete(key: 'password');
  }
}
