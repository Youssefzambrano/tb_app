import 'package:equatable/equatable.dart';
import '../../domain/entities/administrador.dart';

class AdministradorModel extends Administrador with EquatableMixin {
  const AdministradorModel({required int id}) : super(id: id);

  @override
  List<Object?> get props => [id];

  factory AdministradorModel.fromMap(Map<String, dynamic> map) {
    return AdministradorModel(id: map['id']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id};
  }
}
