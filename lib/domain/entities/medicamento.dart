class Medicamento {
  final int id;
  final String nombre;
  final String descripcion;
  final double dosisRecomendada;
  final int frecuencia;
  final int duracion;
  final String? laboratorio;
  final int cantidadPastillas;
  final double peso;
  final String? efectosSecundarios;

  const Medicamento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.dosisRecomendada,
    required this.frecuencia,
    required this.duracion,
    this.laboratorio,
    required this.cantidadPastillas,
    required this.peso,
    this.efectosSecundarios,
  });
}
