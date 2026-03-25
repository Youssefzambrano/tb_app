import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/data/repositories_impl/dosis_repository_impl.dart';
import 'package:tb_app/domain/entities/dosis.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

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
  late DosisRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = DosisRepositoryImpl(supabase: mockSupabase);
  });

  group('DosisRepositoryImpl', () {
    final tDosis = Dosis(
      id: 1,
      idTratamientoPaciente: 10,
      idMedicamento: 5,
      fechaHoraToma: DateTime(2023, 1, 1, 8, 0),
      estado: 'tomada',
    );

    test('registrarDosis inserta datos correctamente', () async {
      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.registrarDosis(tDosis);

      verify(() => mockSupabase.from('dosis')).called(1);
      verify(() => mockDosisQueryBuilder.insert(any())).called(1);
    });

    test('contarDosisPorUsuario retorna cantidad', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();
      final mockDosisBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.select('id'),
      ).thenAnswer((_) => mockDosisBuilder);

      when(() => mockDosisBuilder.eq('id_tratamiento_paciente', 10)).thenAnswer(
        (_) => FakeAwaitableFilterBuilder<PostgrestList>([
          {'id': 1},
          {'id': 2},
        ]),
      );

      final result = await repository.contarDosisPorUsuario(1);

      expect(result, 2);
    });

    test('contarDosisPorUsuario retorna 0 si no hay tratamiento', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      final result = await repository.contarDosisPorUsuario(1);

      expect(result, 0);
    });

    test('obtenerUltimaDosis retorna dosis', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();
      final mockDosisBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.select('*'),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.order('fecha_hora_toma', ascending: false),
      ).thenAnswer((_) => mockDosisBuilder);

      when(() => mockDosisBuilder.limit(1)).thenAnswer((_) => mockDosisBuilder);

      when(() => mockDosisBuilder.maybeSingle()).thenAnswer(
        (_) => FakeMaybeSingleBuilder({
          'id': 1,
          'id_tratamiento_paciente': 10,
          'id_medicamento': 5,
          'fecha_hora_toma': '2023-01-01T08:00:00.000',
          'estado': 'tomada',
        }),
      );

      final result = await repository.obtenerUltimaDosis(1);

      expect(result, isNotNull);
      expect(result?.id, 1);
      expect(result?.idTratamientoPaciente, 10);
      expect(result?.idMedicamento, 5);
      expect(result?.estado, 'tomada');
    });

    test('obtenerUltimaDosis retorna null si no hay tratamiento', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      final result = await repository.obtenerUltimaDosis(1);

      expect(result, isNull);
    });

    test('obtenerUltimaDosis retorna null si el map es inválido', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();
      final mockDosisBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.select('*'),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.order('fecha_hora_toma', ascending: false),
      ).thenAnswer((_) => mockDosisBuilder);

      when(() => mockDosisBuilder.limit(1)).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 'dato_invalido'}));

      final result = await repository.obtenerUltimaDosis(1);

      expect(result, isNull);
    });

    test('existeDosisHoy retorna true si hay dosis', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();
      final mockDosisBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.select('id'),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.gte(any(), any()),
      ).thenAnswer((_) => mockDosisBuilder);

      when(() => mockDosisBuilder.lte(any(), any())).thenAnswer(
        (_) => FakeAwaitableFilterBuilder<PostgrestList>([
          {'id': 1},
        ]),
      );

      final result = await repository.existeDosisHoy(1);

      expect(result, true);
    });

    test('existeDosisHoy retorna false si no hay dosis', () async {
      final mockTratamientoQueryBuilder = MockSupabaseQueryBuilder();
      final mockTratamientoBuilder = MockPostgrestFilterBuilder();

      final mockDosisQueryBuilder = MockSupabaseQueryBuilder();
      final mockDosisBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQueryBuilder);

      when(
        () => mockTratamientoQueryBuilder.select('id'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockTratamientoBuilder);

      when(
        () => mockTratamientoBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('dosis'),
      ).thenAnswer((_) => mockDosisQueryBuilder);

      when(
        () => mockDosisQueryBuilder.select('id'),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.gte(any(), any()),
      ).thenAnswer((_) => mockDosisBuilder);

      when(
        () => mockDosisBuilder.lte(any(), any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<PostgrestList>([]));

      final result = await repository.existeDosisHoy(1);

      expect(result, false);
    });
  });
}
