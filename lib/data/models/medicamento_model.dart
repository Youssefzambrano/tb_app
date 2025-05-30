import '../../domain/entities/medicamento.dart';

class MedicamentoModel extends Medicamento {
  const MedicamentoModel({
    required int id,
    required String nombre,
    required String descripcion,
    required double dosisRecomendada,
    required int frecuencia,
    required int duracion,
    String? laboratorio,
    required int cantidadPastillas,
    required double peso,
    String? efectosSecundarios,
  }) : super(
         id: id,
         nombre: nombre,
         descripcion: descripcion,
         dosisRecomendada: dosisRecomendada,
         frecuencia: frecuencia,
         duracion: duracion,
         laboratorio: laboratorio,
         cantidadPastillas: cantidadPastillas,
         peso: peso,
         efectosSecundarios: efectosSecundarios,
       );

  factory MedicamentoModel.fromMap(Map<String, dynamic> map) {
    return MedicamentoModel(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      dosisRecomendada: map['dosis_recomendada'].toDouble(),
      frecuencia: map['frecuencia'],
      duracion: map['duracion'],
      laboratorio: map['laboratorio'],
      cantidadPastillas: map['cantidad_pastillas'],
      peso: map['peso'].toDouble(),
      efectosSecundarios: map['efectos_secundarios'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'dosis_recomendada': dosisRecomendada,
      'frecuencia': frecuencia,
      'duracion': duracion,
      'laboratorio': laboratorio,
      'cantidad_pastillas': cantidadPastillas,
      'peso': peso,
      'efectos_secundarios': efectosSecundarios,
    };
  }
}
