import '../entities/usuario.dart';

abstract class UsuarioRepository {
  // Autenticación
  Future<Usuario> iniciarSesion(String correo, String contrasena);
  Future<Usuario> registrarUsuario(Usuario usuario);
  Future<void> cerrarSesion();

  // Verificación y recuperación
  Future<void> enviarCorreoVerificacion(String correo);
  Future<void> enviarCorreoRecuperacion(String correo);

  // Perfil
  Future<Usuario?> obtenerUsuarioPorId(int id);
  Future<void> actualizarUsuario(Usuario usuario);

  // Roles
  Future<List<Usuario>> obtenerUsuariosPorRol(String rol);
  Future<String> obtenerRolUsuario(int id);

  // Seguridad
  Future<void> cambiarContrasena(int id, String nuevaContrasena);
  Future<void> eliminarUsuario(int id);
}
