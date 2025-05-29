import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required int id,
    required String correoElectronico,
    required String contrasena,
    required String nombre,
    required DateTime fechaNacimiento,
    required String genero,
    String? direccion,
    String? telefono,
    required String tipoDocumento,
    required String numeroDocumento,
    required DateTime fechaRegistro,
    required DateTime ultimoLogin,
    required String nivelAcceso,
  }) : super(
         id: id,
         correoElectronico: correoElectronico,
         contrasena: contrasena,
         nombre: nombre,
         fechaNacimiento: fechaNacimiento,
         genero: genero,
         direccion: direccion,
         telefono: telefono,
         tipoDocumento: tipoDocumento,
         numeroDocumento: numeroDocumento,
         fechaRegistro: fechaRegistro,
         ultimoLogin: ultimoLogin,
         nivelAcceso: nivelAcceso,
       );

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      correoElectronico: map['correo_electronico'],
      contrasena: map['contraseña'],
      nombre: map['nombre'],
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento']),
      genero: map['genero'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      tipoDocumento: map['tipo_documento'],
      numeroDocumento: map['numero_documento'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      ultimoLogin: DateTime.parse(map['ultimo_login']),
      nivelAcceso: map['nivel_acceso'],
    );
  }

  Map<String, dynamic> toMap({bool excludeAutoFields = true}) {
    final map = {
      'correo_electronico': correoElectronico,
      'contraseña': contrasena,
      'nombre': nombre,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'genero': genero,
      'direccion': direccion,
      'telefono': telefono,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
    };

    if (!excludeAutoFields) {
      map.addAll({
        'fecha_registro': fechaRegistro.toIso8601String(),
        'ultimo_login': ultimoLogin.toIso8601String(),
        'nivel_acceso': nivelAcceso,
      });
    }

    return map;
  }
}
