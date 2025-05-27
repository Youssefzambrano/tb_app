class Usuario {
  final int id;
  final String correoElectronico;
  final String contrasena;
  final String nombre;
  final DateTime fechaNacimiento;
  final String genero;
  final String? direccion;
  final String? telefono;
  final String tipoDocumento;
  final String numeroDocumento;
  final DateTime fechaRegistro;
  final DateTime ultimoLogin;
  final String nivelAcceso;

  const Usuario({
    required this.id,
    required this.correoElectronico,
    required this.contrasena,
    required this.nombre,
    required this.fechaNacimiento,
    required this.genero,
    this.direccion,
    this.telefono,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.fechaRegistro,
    required this.ultimoLogin,
    required this.nivelAcceso,
  });
}
