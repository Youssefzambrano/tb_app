class ModuloEducativo {
  final int id;
  final int idUsuario;
  final String descripcion;
  final String tipoContenido;
  final String enlace;
  final DateTime fechaPublicacion;

  const ModuloEducativo({
    required this.id,
    required this.idUsuario,
    required this.descripcion,
    required this.tipoContenido,
    required this.enlace,
    required this.fechaPublicacion,
  });
}
