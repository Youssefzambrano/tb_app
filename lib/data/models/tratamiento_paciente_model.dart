import '../../domain/entities/tratamiento_paciente.dart';

class TratamientoPacienteModel extends TratamientoPaciente {
  const TratamientoPacienteModel({
    required int? id, // ID opcional
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
    DateTime? fechaInicioFase1,
    DateTime? fechaInicioFase2,
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
         fechaInicioFase1: fechaInicioFase1,
         fechaInicioFase2: fechaInicioFase2,
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
      fechaInicioFase1:
          map['fecha_inicio_fase1'] != null
              ? DateTime.parse(map['fecha_inicio_fase1'])
              : null,
      fechaInicioFase2:
          map['fecha_inicio_fase2'] != null
              ? DateTime.parse(map['fecha_inicio_fase2'])
              : null,
    );
  }

  factory TratamientoPacienteModel.fromEntity(TratamientoPaciente entity) {
    return TratamientoPacienteModel(
      id: entity.id,
      idPaciente: entity.idPaciente,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      fechaInicio: entity.fechaInicio,
      fechaFinalizacion: entity.fechaFinalizacion,
      duracionTotal: entity.duracionTotal,
      estado: entity.estado,
      pesoPaciente: entity.pesoPaciente,
      totalDosis: entity.totalDosis,
      dosisPendientes: entity.dosisPendientes,
      fase1IntensivaActiva: entity.fase1IntensivaActiva,
      fase2ContinuacionActiva: entity.fase2ContinuacionActiva,
      fechaInicioFase1: entity.fechaInicioFase1,
      fechaInicioFase2: entity.fechaInicioFase2,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
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
      'fecha_inicio_fase1': fechaInicioFase1?.toIso8601String(),
      'fecha_inicio_fase2': fechaInicioFase2?.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
