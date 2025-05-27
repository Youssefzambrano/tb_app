class Notificacion {
  final int id;
  final int idUsuario;
  final int? idTratamientoPaciente;
  final String mensaje;
  final DateTime fechaHoraEnvio;
  final String tipoNotificacion;
  final String? motivoNoToma;
  final String? sintomasPresentados;

  const Notificacion({
    required this.id,
    required this.idUsuario,
    this.idTratamientoPaciente,
    required this.mensaje,
    required this.fechaHoraEnvio,
    required this.tipoNotificacion,
    this.motivoNoToma,
    this.sintomasPresentados,
  });
}
