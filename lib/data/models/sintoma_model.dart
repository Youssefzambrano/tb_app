import 'package:equatable/equatable.dart';
import '../../domain/entities/sintoma.dart';

class SintomaModel extends Sintoma with EquatableMixin {
  const SintomaModel({required int id, required String nombre})
    : super(id: id, nombre: nombre);

  // Esta es la clave: le dice a Dart qué campos comparar en los tests
  @override
  List<Object?> get props => [id, nombre];

  factory SintomaModel.fromMap(Map<String, dynamic> map) {
    return SintomaModel(id: map['id'] as int, nombre: map['nombre'] as String);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }
}
