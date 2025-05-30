import '../../domain/entities/administrador.dart';

class AdministradorModel extends Administrador {
  const AdministradorModel({required int id}) : super(id: id);

  factory AdministradorModel.fromMap(Map<String, dynamic> map) {
    return AdministradorModel(id: map['id']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id};
  }
}
