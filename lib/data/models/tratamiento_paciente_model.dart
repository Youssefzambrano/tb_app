import '../../domain/entities/tratamiento_paciente.dart';

class TratamientoPacienteModel extends TratamientoPaciente {
  const TratamientoPacienteModel({
    required int id,
    required int idPaciente,
    required String nombre,
    String? descripcion,
    required DateTime fechaInicio,
    DateTime? fechaFinalizacion,
    required int duracionTotal,
    required String estado,
    double? pesoPaciente,
    required int totalDosis,
    required int dosisPendientes,
    required bool fase1IntensivaActiva,
    required bool fase2ContinuacionActiva,
  }) : super(
         id: id,
         idPaciente: idPaciente,
         nombre: nombre,
         descripcion: descripcion,
         fechaInicio: fechaInicio,
         fechaFinalizacion: fechaFinalizacion,
         duracionTotal: duracionTotal,
         estado: estado,
         pesoPaciente: pesoPaciente,
         totalDosis: totalDosis,
         dosisPendientes: dosisPendientes,
         fase1IntensivaActiva: fase1IntensivaActiva,
         fase2ContinuacionActiva: fase2ContinuacionActiva,
       );

  factory TratamientoPacienteModel.fromMap(Map<String, dynamic> map) {
    return TratamientoPacienteModel(
      id: map['id'],
      idPaciente: map['id_paciente'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFinalizacion:
          map['fecha_finalizacion'] != null
              ? DateTime.parse(map['fecha_finalizacion'])
              : null,
      duracionTotal: map['duracion_total'],
      estado: map['estado'],
      pesoPaciente: map['peso_paciente']?.toDouble(),
      totalDosis: map['total_dosis'],
      dosisPendientes: map['dosis_pendientes'],
      fase1IntensivaActiva: map['fase1_intensiva_activa'],
      fase2ContinuacionActiva: map['fase2_continuacion_activa'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_paciente': idPaciente,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_finalizacion': fechaFinalizacion?.toIso8601String(),
      'duracion_total': duracionTotal,
      'estado': estado,
      'peso_paciente': pesoPaciente,
      'total_dosis': totalDosis,
      'dosis_pendientes': dosisPendientes,
      'fase1_intensiva_activa': fase1IntensivaActiva,
      'fase2_continuacion_activa': fase2ContinuacionActiva,
    };
  }
}
