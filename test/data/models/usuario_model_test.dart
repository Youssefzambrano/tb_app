import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/models/usuario_model.dart';
import 'package:tb_app/domain/entities/usuario.dart';

void main() {
  final tFecha = DateTime(2024, 1, 1);

  final tUsuarioModel = UsuarioModel(
    id: 1,
    correoElectronico: 'test@test.com',
    contrasena: '123456',
    nombre: 'Kevin Test',
    fechaNacimiento: tFecha,
    genero: 'M',
    tipoDocumento: 'CC',
    numeroDocumento: '12345',
    fechaRegistro: tFecha,
    ultimoLogin: tFecha,
    nivelAcceso: 'paciente',
    direccion: 'Calle 123',
    telefono: '300123',
  );

  group('UsuarioModel', () {
    test('debe ser una subclase de la entidad Usuario', () {
      expect(tUsuarioModel, isA<Usuario>());
    });

    group('toMap', () {
      test(
        'debe excluir campos automáticos por defecto (cobertura líneas base)',
        () {
          final result = tUsuarioModel.toMap();
          expect(result.containsKey('fecha_registro'), false);
          expect(result.containsKey('ultimo_login'), false);
        },
      );

      // ESTE ES EL TEST QUE MATA LAS LÍNEAS ROJAS (66-69)
      test(
        'debe incluir campos automáticos cuando excludeAutoFields es false',
        () {
          // Act
          final result = tUsuarioModel.toMap(excludeAutoFields: false);

          // Assert
          expect(result['fecha_registro'], tFecha.toIso8601String());
          expect(result['ultimo_login'], tFecha.toIso8601String());
          expect(result['nivel_acceso'], 'paciente');
        },
      );
    });

    group('fromMap', () {
      test('debe retornar un modelo válido desde el Map', () {
        final Map<String, dynamic> map = {
          'id': 1,
          'correo_electronico': 'test@test.com',
          'contraseña': '123456',
          'nombre': 'Kevin Test',
          'fecha_nacimiento': '2024-01-01T00:00:00.000',
          'genero': 'M',
          'tipo_documento': 'CC',
          'numero_documento': '12345',
          'fecha_registro': '2024-01-01T00:00:00.000',
          'ultimo_login': '2024-01-01T00:00:00.000',
          'nivel_acceso': 'paciente',
        };

        final result = UsuarioModel.fromMap(map);
        expect(result.correoElectronico, tUsuarioModel.correoElectronico);
      });
    });
  });
}
