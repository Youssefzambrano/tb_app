import '../../domain/entities/enfermero.dart';

class EnfermeroModel extends Enfermero {
  const EnfermeroModel({required int id}) : super(id: id);

  factory EnfermeroModel.fromMap(Map<String, dynamic> map) {
    return EnfermeroModel(id: map['id']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id};
  }
}
