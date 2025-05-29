import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../models/usuario_model.dart';
import '../datasources/remote/supabase/auth_supabase_service.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final SupabaseClient supabase;
  final AuthSupabaseService authService;

  UsuarioRepositoryImpl({required this.supabase, required this.authService});

  @override
  Future<Usuario> registrarUsuario(Usuario usuario) async {
    // Solo insertamos en la tabla USUARIO porque ya está registrado en auth
    final usuarioModel = UsuarioModel(
      id: 0, // Ignorado por la BD
      correoElectronico: usuario.correoElectronico,
      contrasena: usuario.contrasena,
      nombre: usuario.nombre,
      fechaNacimiento: usuario.fechaNacimiento,
      genero: usuario.genero,
      direccion: usuario.direccion,
      telefono: usuario.telefono,
      tipoDocumento: usuario.tipoDocumento,
      numeroDocumento: usuario.numeroDocumento,
      fechaRegistro: DateTime.now(),
      ultimoLogin: DateTime.now(),
      nivelAcceso: 'Basico',
    );

    try {
      await supabase.from('usuario').insert(usuarioModel.toMap());
    } catch (e) {
      throw Exception('Error al registrar el usuario en la base de datos.');
    }

    final data =
        await supabase
            .from('usuario')
            .select()
            .eq('correo_electronico', usuario.correoElectronico)
            .single();

    return UsuarioModel.fromMap(data);
  }

  @override
  Future<Usuario> iniciarSesion(String correo, String contrasena) async {
    await authService.signInWithEmail(email: correo, password: contrasena);

    final data =
        await supabase
            .from('usuario')
            .select()
            .eq('correo_electronico', correo)
            .single();

    return UsuarioModel.fromMap(data);
  }

  @override
  Future<void> cerrarSesion() async {
    await authService.signOut();
  }

  @override
  Future<void> enviarCorreoRecuperacion(String correo) async {
    await authService.resetPassword(correo);
  }

  @override
  Future<void> enviarCorreoVerificacion(String correo) async {
    throw UnimplementedError(
      'Supabase no permite reenviar verificación desde Flutter directamente.',
    );
  }

  @override
  Future<Usuario?> obtenerUsuarioPorId(int id) async {
    final data =
        await supabase.from('usuario').select().eq('id', id).maybeSingle();

    if (data == null) return null;
    return UsuarioModel.fromMap(data);
  }

  @override
  Future<void> actualizarUsuario(Usuario usuario) async {
    final usuarioModel = usuario as UsuarioModel;
    await supabase
        .from('usuario')
        .update(usuarioModel.toMap())
        .eq('id', usuario.id);
  }

  @override
  Future<List<Usuario>> obtenerUsuariosPorRol(String rol) async {
    final data = await supabase
        .from('usuario')
        .select()
        .eq('nivel_acceso', rol);

    return (data as List).map((item) => UsuarioModel.fromMap(item)).toList();
  }

  @override
  Future<String> obtenerRolUsuario(int id) async {
    final data =
        await supabase
            .from('usuario')
            .select('nivel_acceso')
            .eq('id', id)
            .single();

    return data['nivel_acceso'];
  }

  @override
  Future<void> cambiarContrasena(int id, String nuevaContrasena) async {
    throw UnimplementedError(
      'Cambio de contraseña debe hacerse desde Supabase Auth directamente.',
    );
  }

  @override
  Future<void> eliminarUsuario(int id) async {
    await supabase.from('usuario').delete().eq('id', id);
  }
}
