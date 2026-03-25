import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/data/repositories_impl/tratamiento_repository_impl.dart';
import 'package:tb_app/domain/entities/tratamiento_paciente.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f1.dart';
import 'package:tb_app/domain/entities/medicacion_paciente_f2.dart';
import 'package:tb_app/domain/entities/seguimiento_paciente.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockPostgrestTransformBuilderList extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {}

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

class FakeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap value;

  FakeSingleBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap value) onValue, {
    Function? onError,
  }) {
    return Future<PostgrestMap>.value(value).then<R>(onValue, onError: onError);
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
  late TratamientoRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = TratamientoRepositoryImpl(supabase: mockSupabase);
  });

  group('TratamientoRepositoryImpl', () {
    final tratamiento = TratamientoPaciente(
      id: 0,
      idPaciente: 1,
      nombre: 'Tratamiento TB sensible',
      fechaInicio: DateTime(2023, 1, 1),
      fechaInicioFase1: DateTime(2023, 1, 1),
      fechaInicioFase2: null,
      duracionTotal: 168,
      totalDosis: 168,
      dosisPendientes: 168,
      estado: 'En curso',
      fase1IntensivaActiva: true,
      fase2ContinuacionActiva: false,
    );

    final medicacionF1 = MedicacionPacienteF1(
      id: 0,
      idTratamientoPaciente: 0,
      idMedicamento: 1,
      dosisDiaria: 1,
      frecuencia: 1,
      duracion: 56,
    );

    final medicacionF2 = MedicacionPacienteF2(
      id: 0,
      idTratamientoPaciente: 0,
      idMedicamento: 2,
      dosisDiaria: 1,
      frecuencia: 1,
      duracion: 112,
    );

    final seguimiento = SeguimientoPaciente(
      id: 0,
      idPaciente: 1,
      idTratamientoPaciente: 0,
      fechaReporte: DateTime(2023, 1, 1),
      dosisOmitidas: 0,
    );

    test('insertarTratamiento retorna id creado', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformListBuilder = MockPostgrestTransformBuilderList();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.insert(any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.select(),
      ).thenAnswer((_) => mockTransformListBuilder);

      when(
        () => mockTransformListBuilder.single(),
      ).thenAnswer((_) => FakeSingleBuilder({'id': 10}));

      final result = await repository.insertarTratamiento(tratamiento);

      expect(result, 10);
    });

    test('insertarMedicacionF1 inserta correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.insertarMedicacionF1(medicacionF1);

      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('insertarMedicacionF2 inserta correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('medicacion_paciente_f2'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.insertarMedicacionF2(medicacionF2);

      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('insertarSeguimiento inserta correctamente', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('seguimiento_paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.insertarSeguimiento(seguimiento);

      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('iniciarTratamientoCompleto ejecuta flujo completo', () async {
      final mockTratamientoQB = MockSupabaseQueryBuilder();
      final mockTratamientoFB = MockPostgrestFilterBuilder();
      final mockTransformListBuilder = MockPostgrestTransformBuilderList();

      final mockF1QB = MockSupabaseQueryBuilder();
      final mockF2QB = MockSupabaseQueryBuilder();
      final mockSegQB = MockSupabaseQueryBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockTratamientoQB);

      when(
        () => mockTratamientoQB.insert(any()),
      ).thenAnswer((_) => mockTratamientoFB);

      when(
        () => mockTratamientoFB.select(),
      ).thenAnswer((_) => mockTransformListBuilder);

      when(
        () => mockTransformListBuilder.single(),
      ).thenAnswer((_) => FakeSingleBuilder({'id': 10}));

      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => mockF1QB);

      when(
        () => mockF1QB.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      when(
        () => mockSupabase.from('medicacion_paciente_f2'),
      ).thenAnswer((_) => mockF2QB);

      when(
        () => mockF2QB.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      when(
        () => mockSupabase.from('seguimiento_paciente'),
      ).thenAnswer((_) => mockSegQB);

      when(
        () => mockSegQB.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.iniciarTratamientoCompleto(
        tratamiento: tratamiento,
        medicacionF1: medicacionF1,
        medicacionF2: medicacionF2,
        seguimiento: seguimiento,
      );

      verify(() => mockTratamientoQB.insert(any())).called(1);
      verify(() => mockF1QB.insert(any())).called(1);
      verify(() => mockF2QB.insert(any())).called(1);
      verify(() => mockSegQB.insert(any())).called(1);
    });

    test('obtenerTratamientoActivo retorna tratamiento', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockFilterBuilder);

      when(() => mockFilterBuilder.maybeSingle()).thenAnswer(
        (_) => FakeMaybeSingleBuilder({
          'id': 10,
          'id_paciente': 1,
          'nombre': 'Tratamiento TB sensible',
          'fecha_inicio': '2023-01-01',
          'fecha_inicio_fase1': '2023-01-01',
          'fecha_inicio_fase2': null,
          'duracion_total': 168,
          'total_dosis': 168,
          'dosis_pendientes': 168,
          'estado': 'En curso',
          'fase1_intensiva_activa': true,
          'fase2_continuacion_activa': false,
        }),
      );

      final result = await repository.obtenerTratamientoActivo(1);

      expect(result.idPaciente, 1);
      expect(result.estado, 'En curso');
    });

    test('obtenerTratamientoActivo lanza excepción si no existe', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('id_paciente', 1),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq('estado', 'En curso'),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      expect(
        () => repository.obtenerTratamientoActivo(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
