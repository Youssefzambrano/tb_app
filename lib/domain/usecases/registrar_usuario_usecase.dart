import '../entities/usuario.dart';
import '../repositories/usuario_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarUsuarioUseCase {
  final UsuarioRepository repository;

  RegistrarUsuarioUseCase(this.repository);

  Future<Usuario> call({
    required String nombre,
    required DateTime fechaNacimiento,
    required String genero,
    required String tipoDocumento,
    required String numeroDocumento,
    String? direccion,
    String? telefono,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'No hay usuario autenticado. Asegúrate de haber confirmado el correo.',
      );
    }

    final usuario = Usuario(
      id: 0,
      correoElectronico: user.email ?? '',
      contrasena: '',
      nombre: nombre,
      fechaNacimiento: fechaNacimiento,
      genero: genero,
      direccion: direccion,
      telefono: telefono,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      fechaRegistro: DateTime.now(),
      ultimoLogin: DateTime.now(),
      nivelAcceso: 'Basico',
    );

    return await repository.registrarUsuario(usuario);
  }
}
