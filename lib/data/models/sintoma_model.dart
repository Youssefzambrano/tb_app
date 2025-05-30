import '../../domain/entities/sintoma.dart';

class SintomaModel extends Sintoma {
  const SintomaModel({required int id, required String nombre})
    : super(id: id, nombre: nombre);

  factory SintomaModel.fromMap(Map<String, dynamic> map) {
    return SintomaModel(id: map['id'], nombre: map['nombre']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }
}
