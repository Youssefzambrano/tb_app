import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tb_app/data/repositories_impl/medicacion_repository_impl.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

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
  late MedicacionRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    repository = MedicacionRepositoryImpl(supabase: mockSupabase);
  });

  group('MedicacionRepositoryImpl', () {
    test('obtenerIdMedicamentoF1 retorna id cuando existe', () async {
      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('id_medicamento'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id_medicamento': 5}));

      final result = await repository.obtenerIdMedicamentoF1(10);

      expect(result, 5);
    });

    test('obtenerIdMedicamentoF1 lanza excepción si no existe', () async {
      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('id_medicamento'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id_tratamiento_paciente', 10),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      expect(
        () => repository.obtenerIdMedicamentoF1(10),
        throwsA(isA<Exception>()),
      );
    });

    test('obtenerIdMedicamentoF2 retorna id cuando existe', () async {
      when(
        () => mockSupabase.from('medicacion_paciente_f2'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('id_medicamento'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id_tratamiento_paciente', 20),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id_medicamento': 8}));

      final result = await repository.obtenerIdMedicamentoF2(20);

      expect(result, 8);
    });

    test('obtenerIdMedicamentoF2 lanza excepción si no existe', () async {
      when(
        () => mockSupabase.from('medicacion_paciente_f2'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('id_medicamento'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id_tratamiento_paciente', 20),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      expect(
        () => repository.obtenerIdMedicamentoF2(20),
        throwsA(isA<Exception>()),
      );
    });

    test('obtenerNombreMedicamento retorna nombre cuando existe', () async {
      when(
        () => mockSupabase.from('medicamento'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('nombre'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id', 3),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'nombre': 'Isoniazida'}));

      final result = await repository.obtenerNombreMedicamento(3);

      expect(result, 'Isoniazida');
    });

    test('obtenerNombreMedicamento lanza excepción si no existe', () async {
      when(
        () => mockSupabase.from('medicamento'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('nombre'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id', 3),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      expect(
        () => repository.obtenerNombreMedicamento(3),
        throwsA(isA<Exception>()),
      );
    });
  });
}
