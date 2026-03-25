import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/data/models/paciente_model.dart';
import 'package:tb_app/data/repositories_impl/paciente_repository_impl.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestMap?> {}

class FakeAwaitableFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final T value;

  FakeAwaitableFilterBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future<T>.value(value).then<R>(onValue, onError: onError);
  }
}

class FakeMaybeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? value;

  FakeMaybeSingleBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap? value) onValue, {
    Function? onError,
  }) {
    return Future<PostgrestMap?>.value(
      value,
    ).then<R>(onValue, onError: onError);
  }
}

void main() {
  late PacienteRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = PacienteRepositoryImpl(supabase: mockSupabase);
  });

  group('PacienteRepositoryImpl', () {
    final paciente = PacienteModel(
      id: 1,
      fechaDiagnostico: DateTime(2023, 1, 1),
      tipoTuberculosis: 'Sensible',
      estadoTratamiento: 'Activo',
      nombreContactoEmergencia: 'Maria',
      telefonoContactoEmergencia: '3000000000',
    );

    test('registrarPaciente inserta correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.registrarPaciente(paciente);

      verify(() => mockSupabase.from('paciente')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('obtenerPacientePorId retorna paciente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id', 1),
      ).thenAnswer((_) => mockFilterBuilder);

      when(() => mockFilterBuilder.maybeSingle()).thenAnswer(
        (_) => FakeMaybeSingleBuilder({
          'id': 1,
          'fecha_diagnostico': '2023-01-01',
          'tipo_tuberculosis': 'Sensible',
          'estado_tratamiento': 'Activo',
          'nombre_contacto_emergencia': 'Maria',
          'telefono_contacto_emergencia': '3000000000',
        }),
      );

      final result = await repository.obtenerPacientePorId(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.nombreContactoEmergencia, 'Maria');
    });

    test('obtenerPacientePorId retorna null si no existe', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id', 1),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      final result = await repository.obtenerPacientePorId(1);

      expect(result, isNull);
    });

    test('actualizarPaciente actualiza correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.update(any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id', 1),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<PostgrestList>([]));

      await repository.actualizarPaciente(paciente);

      verify(() => mockSupabase.from('paciente')).called(1);
      verify(() => mockQueryBuilder.update(any())).called(1);
    });

    test('eliminarPaciente elimina correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.delete(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id', 1),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<PostgrestList>([]));

      await repository.eliminarPaciente(1);

      verify(() => mockSupabase.from('paciente')).called(1);
      verify(() => mockQueryBuilder.delete()).called(1);
    });
  });
}
