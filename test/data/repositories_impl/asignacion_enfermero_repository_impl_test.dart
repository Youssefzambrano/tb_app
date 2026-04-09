import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tb_app/data/datasources/remote/supabase/asignacion_enfermero_remote_datasource.dart';
import 'package:tb_app/data/repositories_impl/asignacion_enfermero_repository_impl.dart';

class MockRemoteDataSource extends Mock
    implements AsignacionEnfermeroRemoteDataSource {}

void main() {
  group('AsignacionEnfermeroRepositoryImpl', () {
    late MockRemoteDataSource mockRemote;
    late AsignacionEnfermeroRepositoryImpl repository;

    setUp(() {
      mockRemote = MockRemoteDataSource();
      repository = AsignacionEnfermeroRepositoryImpl(
        remoteDataSource: mockRemote,
        random: Random(1),
      );
    });

    test('retorna asignación existente si ya hay enfermero', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => {'id_enfermero': 2});

      when(
        () => mockRemote.obtenerNombreUsuario(2),
      ).thenAnswer((_) async => 'Laura');

      final result = await repository.asignarEnfermeroBalanceado(idPaciente: 1);

      expect(result, isNotNull);
      expect(result!.idEnfermero, 2);
      expect(result.nombreEnfermero, 'Laura');
    });

    test('retorna null si no hay enfermeros en ninguna tabla', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => null);

      when(() => mockRemote.obtenerEnfermeros()).thenAnswer((_) async => []);

      when(
        () => mockRemote.obtenerUsuariosEnfermero(),
      ).thenAnswer((_) async => []);

      final result = await repository.asignarEnfermeroBalanceado(idPaciente: 1);

      expect(result, isNull);
    });

    test('usa fallback de usuario si tabla enfermero está vacía', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => null);

      when(() => mockRemote.obtenerEnfermeros()).thenAnswer((_) async => []);

      when(() => mockRemote.obtenerUsuariosEnfermero()).thenAnswer(
        (_) async => [
          {'id': 1, 'nombre_enfermero': 'Ana'},
          {'id': 2, 'nombre_enfermero': 'Luis'},
        ],
      );

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(1),
      ).thenAnswer((_) async => 0);

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(2),
      ).thenAnswer((_) async => 2);

      when(
        () => mockRemote.insertarAsignacion(idPaciente: 1, idEnfermero: 1),
      ).thenAnswer((_) async {});

      final result = await repository.asignarEnfermeroBalanceado(idPaciente: 1);

      expect(result!.idEnfermero, 1);
      expect(result.nombreEnfermero, 'Ana');
    });

    test('asigna enfermero con menor carga', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => null);

      when(() => mockRemote.obtenerEnfermeros()).thenAnswer(
        (_) async => [
          {'id': 1, 'nombre_enfermero': 'Ana'},
          {'id': 2, 'nombre_enfermero': 'Luis'},
        ],
      );

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(1),
      ).thenAnswer((_) async => 3);

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(2),
      ).thenAnswer((_) async => 1);

      when(
        () => mockRemote.insertarAsignacion(idPaciente: 1, idEnfermero: 2),
      ).thenAnswer((_) async {});

      final result = await repository.asignarEnfermeroBalanceado(idPaciente: 1);

      expect(result!.idEnfermero, 2);
      expect(result.nombreEnfermero, 'Luis');
    });

    test('busca nombre si viene vacío', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => null);

      when(() => mockRemote.obtenerEnfermeros()).thenAnswer(
        (_) async => [
          {'id': 1, 'nombre_enfermero': ''},
        ],
      );

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(1),
      ).thenAnswer((_) async => 0);

      when(
        () => mockRemote.insertarAsignacion(idPaciente: 1, idEnfermero: 1),
      ).thenAnswer((_) async {});

      when(
        () => mockRemote.obtenerNombreUsuario(1),
      ).thenAnswer((_) async => 'Carlos');

      final result = await repository.asignarEnfermeroBalanceado(idPaciente: 1);

      expect(result!.nombreEnfermero, 'Carlos');
    });

    test('lanza error si falla inserción', () async {
      when(
        () => mockRemote.obtenerAsignacionExistente(1),
      ).thenAnswer((_) async => null);

      when(() => mockRemote.obtenerEnfermeros()).thenAnswer(
        (_) async => [
          {'id': 1, 'nombre_enfermero': 'Ana'},
        ],
      );

      when(
        () => mockRemote.contarAsignacionesPorEnfermero(1),
      ).thenAnswer((_) async => 0);

      when(
        () => mockRemote.insertarAsignacion(idPaciente: 1, idEnfermero: 1),
      ).thenThrow(Exception('db error'));

      expect(
        () => repository.asignarEnfermeroBalanceado(idPaciente: 1),
        throwsException,
      );
    });
  });
}
