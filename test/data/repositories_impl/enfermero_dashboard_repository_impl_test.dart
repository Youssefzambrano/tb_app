import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tb_app/data/repositories_impl/enfermero_dashboard_repository_impl.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockFilterBuilderList extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockFilterBuilderDynamic extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockTransformBuilderList extends Mock
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

class FakeTransformListBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList value;

  FakeTransformListBuilder(this.value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    return Future<PostgrestList>.value(
      value,
    ).then<R>(onValue, onError: onError);
  }
}

void main() {
  late EnfermeroDashboardRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = EnfermeroDashboardRepositoryImpl(supabase: mockSupabase);
  });

  group('EnfermeroDashboardRepositoryImpl', () {
    test(
      'obtenerResumenPacientesAsignados retorna vacio si no hay asignaciones',
      () async {
        final qbAsignacion = MockQueryBuilder();
        final fbAsignacion = MockFilterBuilderList();

        when(
          () => mockSupabase.from('paciente_enfermero'),
        ).thenAnswer((_) => qbAsignacion);
        when(
          () => qbAsignacion.select('id_paciente'),
        ).thenAnswer((_) => fbAsignacion);
        when(
          () => fbAsignacion.eq('id_enfermero', 1),
        ).thenAnswer((_) => FakeAwaitableFilterBuilder<PostgrestList>([]));

        final result = await repository.obtenerResumenPacientesAsignados(1);

        expect(result, isEmpty);
      },
    );

    test(
      'obtenerResumenPacientesAsignados construye resumen completo del paciente',
      () async {
        final qbAsignacion = MockQueryBuilder();
        final fbAsignacion = MockFilterBuilderList();

        final qbUsuario = MockQueryBuilder();
        final fbUsuario = MockFilterBuilderList();

        final qbTratamiento = MockQueryBuilder();
        final fbTratamiento = MockFilterBuilderList();

        final qbDosisTotal = MockQueryBuilder();
        final fbDosisTotal = MockFilterBuilderList();

        final qbDosisHoy = MockQueryBuilder();
        final fbDosisHoy = MockFilterBuilderList();

        final qbSeguimiento = MockQueryBuilder();
        final fbSeguimiento = MockFilterBuilderList();

        final qbSintomasPaciente = MockQueryBuilder();
        final fbSintomasPaciente = MockFilterBuilderList();
        final tbSintomasPaciente = FakeTransformListBuilder([
          {'id': 900},
        ]);

        when(
          () => mockSupabase.from('paciente_enfermero'),
        ).thenAnswer((_) => qbAsignacion);
        when(
          () => qbAsignacion.select('id_paciente'),
        ).thenAnswer((_) => fbAsignacion);
        when(() => fbAsignacion.eq('id_enfermero', 7)).thenAnswer(
          (_) => FakeAwaitableFilterBuilder<PostgrestList>([
            {'id_paciente': 10},
          ]),
        );

        when(() => mockSupabase.from('usuario')).thenAnswer((_) => qbUsuario);
        when(
          () => qbUsuario.select('nombre, correo_electronico'),
        ).thenAnswer((_) => fbUsuario);
        when(() => fbUsuario.eq('id', 10)).thenAnswer((_) => fbUsuario);
        when(() => fbUsuario.single()).thenAnswer(
          (_) => FakeSingleBuilder({
            'nombre': 'Ana Torres',
            'correo_electronico': 'ana@test.com',
          }),
        );

        when(
          () => mockSupabase.from('tratamiento_paciente'),
        ).thenAnswer((_) => qbTratamiento);
        when(
          () => qbTratamiento.select(
            'id, estado, total_dosis, fase1_intensiva_activa, fase2_continuacion_activa',
          ),
        ).thenAnswer((_) => fbTratamiento);
        when(
          () => fbTratamiento.eq('id_paciente', 10),
        ).thenAnswer((_) => fbTratamiento);
        when(
          () => fbTratamiento.eq('estado', 'En curso'),
        ).thenAnswer((_) => fbTratamiento);
        when(() => fbTratamiento.maybeSingle()).thenAnswer(
          (_) => FakeMaybeSingleBuilder({
            'id': 100,
            'estado': 'En curso',
            'total_dosis': 60,
            'fase1_intensiva_activa': true,
            'fase2_continuacion_activa': false,
          }),
        );

        var dosisFromCallCount = 0;
        when(() => mockSupabase.from('dosis')).thenAnswer((_) {
          dosisFromCallCount++;
          return dosisFromCallCount == 1 ? qbDosisTotal : qbDosisHoy;
        });

        when(() => qbDosisTotal.select('id')).thenAnswer((_) => fbDosisTotal);
        when(() => fbDosisTotal.eq('id_tratamiento_paciente', 100)).thenAnswer(
          (_) => FakeAwaitableFilterBuilder<PostgrestList>([
            {'id': 1},
            {'id': 2},
          ]),
        );

        when(() => qbDosisHoy.select('id')).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.eq('id_tratamiento_paciente', 100),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.gte('fecha_hora_toma', any()),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.lte('fecha_hora_toma', any()),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.maybeSingle(),
        ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 2}));

        when(
          () => mockSupabase.from('seguimiento_paciente'),
        ).thenAnswer((_) => qbSeguimiento);
        when(() => qbSeguimiento.select('id')).thenAnswer((_) => fbSeguimiento);
        when(
          () => fbSeguimiento.eq('id_paciente', 10),
        ).thenAnswer((_) => fbSeguimiento);
        when(
          () => fbSeguimiento.eq('id_tratamiento_paciente', 100),
        ).thenAnswer((_) => fbSeguimiento);
        when(() => fbSeguimiento.eq('fecha_reporte', any())).thenAnswer(
          (_) => FakeAwaitableFilterBuilder<PostgrestList>([
            {'id': 500},
          ]),
        );

        when(
          () => mockSupabase.from('sintomas_paciente'),
        ).thenAnswer((_) => qbSintomasPaciente);
        when(
          () => qbSintomasPaciente.select('id'),
        ).thenAnswer((_) => fbSintomasPaciente);
        when(
          () => fbSintomasPaciente.inFilter('id_seguimiento', [500]),
        ).thenAnswer((_) => fbSintomasPaciente);
        when(
          () => fbSintomasPaciente.limit(1),
        ).thenAnswer((_) => tbSintomasPaciente);

        final result = await repository.obtenerResumenPacientesAsignados(7);

        expect(result.length, 1);

        final paciente = result.first;
        expect(paciente.idPaciente, 10);
        expect(paciente.idTratamiento, 100);
        expect(paciente.nombrePaciente, 'Ana Torres');
        expect(paciente.correoPaciente, 'ana@test.com');
        expect(paciente.faseActual, 'Intensiva');
        expect(paciente.estadoTratamiento, 'En curso');
        expect(paciente.dosisTomadas, 2);
        expect(paciente.dosisTotales, 60);
        expect(paciente.dosisHoyTomada, isTrue);
        expect(paciente.reportoSintomasHoy, isTrue);
        expect(paciente.prioridadClinica, 3);
        expect(paciente.adherencia, closeTo(3.3333, 0.001));
        expect(paciente.tieneAlerta, isTrue);
      },
    );

    test(
      'validarTomaPaciente actualiza la dosis de hoy si ya existe',
      () async {
        final qbDosis = MockQueryBuilder();
        final fbDosisHoy = MockFilterBuilderList();
        final fbUpdate = MockFilterBuilderDynamic();

        when(() => mockSupabase.from('dosis')).thenAnswer((_) => qbDosis);

        when(() => qbDosis.select('id')).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.eq('id_tratamiento_paciente', 100),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.gte('fecha_hora_toma', any()),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.lte('fecha_hora_toma', any()),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.order('fecha_hora_toma', ascending: false),
        ).thenAnswer((_) => fbDosisHoy);
        when(
          () => fbDosisHoy.maybeSingle(),
        ).thenAnswer((_) => FakeMaybeSingleBuilder({'id': 55}));

        when(
          () => qbDosis.update({'estado': 'Tomada'}),
        ).thenAnswer((_) => fbUpdate);
        when(
          () => fbUpdate.eq('id', 55),
        ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

        await repository.validarTomaPaciente(
          idPaciente: 10,
          idTratamientoPaciente: 100,
          estado: 'Tomada',
        );

        verify(() => qbDosis.update({'estado': 'Tomada'})).called(1);
        verify(() => fbUpdate.eq('id', 55)).called(1);
      },
    );

    test('validarTomaPaciente inserta dosis si no existe una hoy', () async {
      final qbDosis = MockQueryBuilder();
      final fbDosisHoy = MockFilterBuilderList();

      final qbTratamiento = MockQueryBuilder();
      final fbTratamiento = MockFilterBuilderList();

      final qbMedicacion = MockQueryBuilder();
      final fbMedicacion = MockFilterBuilderList();

      when(() => mockSupabase.from('dosis')).thenAnswer((_) => qbDosis);
      when(() => qbDosis.select('id')).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.eq('id_tratamiento_paciente', 100),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.gte('fecha_hora_toma', any()),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.lte('fecha_hora_toma', any()),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.order('fecha_hora_toma', ascending: false),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => qbTratamiento);
      when(
        () => qbTratamiento.select('fase1_intensiva_activa'),
      ).thenAnswer((_) => fbTratamiento);
      when(() => fbTratamiento.eq('id', 100)).thenAnswer((_) => fbTratamiento);
      when(
        () => fbTratamiento.eq('id_paciente', 10),
      ).thenAnswer((_) => fbTratamiento);
      when(
        () => fbTratamiento.single(),
      ).thenAnswer((_) => FakeSingleBuilder({'fase1_intensiva_activa': true}));

      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => qbMedicacion);
      when(
        () => qbMedicacion.select('id_medicamento'),
      ).thenAnswer((_) => fbMedicacion);
      when(
        () => fbMedicacion.eq('id_tratamiento_paciente', 100),
      ).thenAnswer((_) => fbMedicacion);
      when(
        () => fbMedicacion.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder({'id_medicamento': 8}));

      when(
        () => qbDosis.insert(any()),
      ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

      await repository.validarTomaPaciente(
        idPaciente: 10,
        idTratamientoPaciente: 100,
        estado: 'Omitida',
      );

      verify(() => qbDosis.insert(any())).called(1);
    });

    test('validarTomaPaciente lanza excepcion si no hay medicacion', () async {
      final qbDosis = MockQueryBuilder();
      final fbDosisHoy = MockFilterBuilderList();

      final qbTratamiento = MockQueryBuilder();
      final fbTratamiento = MockFilterBuilderList();

      final qbMedicacion = MockQueryBuilder();
      final fbMedicacion = MockFilterBuilderList();

      when(() => mockSupabase.from('dosis')).thenAnswer((_) => qbDosis);
      when(() => qbDosis.select('id')).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.eq('id_tratamiento_paciente', 100),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.gte('fecha_hora_toma', any()),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.lte('fecha_hora_toma', any()),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.order('fecha_hora_toma', ascending: false),
      ).thenAnswer((_) => fbDosisHoy);
      when(
        () => fbDosisHoy.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      when(
        () => mockSupabase.from('tratamiento_paciente'),
      ).thenAnswer((_) => qbTratamiento);
      when(
        () => qbTratamiento.select('fase1_intensiva_activa'),
      ).thenAnswer((_) => fbTratamiento);
      when(() => fbTratamiento.eq('id', 100)).thenAnswer((_) => fbTratamiento);
      when(
        () => fbTratamiento.eq('id_paciente', 10),
      ).thenAnswer((_) => fbTratamiento);
      when(
        () => fbTratamiento.single(),
      ).thenAnswer((_) => FakeSingleBuilder({'fase1_intensiva_activa': true}));

      when(
        () => mockSupabase.from('medicacion_paciente_f1'),
      ).thenAnswer((_) => qbMedicacion);
      when(
        () => qbMedicacion.select('id_medicamento'),
      ).thenAnswer((_) => fbMedicacion);
      when(
        () => fbMedicacion.eq('id_tratamiento_paciente', 100),
      ).thenAnswer((_) => fbMedicacion);
      when(
        () => fbMedicacion.maybeSingle(),
      ).thenAnswer((_) => FakeMaybeSingleBuilder(null));

      expect(
        () => repository.validarTomaPaciente(
          idPaciente: 10,
          idTratamientoPaciente: 100,
          estado: 'Tomada',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('obtenerCatalogoSintomas retorna lista mapeada', () async {
      final qbSintoma = MockQueryBuilder();
      final fbSintoma = MockFilterBuilderList();

      when(() => mockSupabase.from('sintoma')).thenAnswer((_) => qbSintoma);
      when(() => qbSintoma.select('id, nombre')).thenAnswer((_) => fbSintoma);
      when(() => fbSintoma.order('nombre')).thenAnswer(
        (_) => FakeAwaitableFilterBuilder<PostgrestList>([
          {'id': 1, 'nombre': 'Fiebre'},
          {'id': 2, 'nombre': 'Tos'},
        ]),
      );

      final result = await repository.obtenerCatalogoSintomas();

      expect(result.length, 2);
      expect(result.first.id, 1);
      expect(result.first.nombre, 'Fiebre');
      expect(result.last.nombre, 'Tos');
    });

    test(
      'registrarSeguimientoClinico inserta seguimiento sin sintomas',
      () async {
        final qbSeguimiento = MockQueryBuilder();
        final fbInsert = MockFilterBuilderDynamic();
        final tbSelect = MockTransformBuilderList();
        final qbSintomasPaciente = MockQueryBuilder();

        when(
          () => mockSupabase.from('seguimiento_paciente'),
        ).thenAnswer((_) => qbSeguimiento);
        when(() => qbSeguimiento.insert(any())).thenAnswer((_) => fbInsert);
        when(() => fbInsert.select('id')).thenAnswer((_) => tbSelect);
        when(
          () => tbSelect.single(),
        ).thenAnswer((_) => FakeSingleBuilder({'id': 77}));

        when(
          () => mockSupabase.from('sintomas_paciente'),
        ).thenAnswer((_) => qbSintomasPaciente);

        await repository.registrarSeguimientoClinico(
          idPaciente: 10,
          idTratamientoPaciente: 100,
          dosisOmitidas: 1,
          idsSintomas: [],
        );

        verify(() => qbSeguimiento.insert(any())).called(1);
        verifyNever(() => qbSintomasPaciente.insert(any()));
      },
    );

    test(
      'registrarSeguimientoClinico inserta seguimiento y sintomas',
      () async {
        final qbSeguimiento = MockQueryBuilder();
        final fbInsert = MockFilterBuilderDynamic();
        final tbSelect = MockTransformBuilderList();
        final qbSintomasPaciente = MockQueryBuilder();

        when(
          () => mockSupabase.from('seguimiento_paciente'),
        ).thenAnswer((_) => qbSeguimiento);
        when(() => qbSeguimiento.insert(any())).thenAnswer((_) => fbInsert);
        when(() => fbInsert.select('id')).thenAnswer((_) => tbSelect);
        when(
          () => tbSelect.single(),
        ).thenAnswer((_) => FakeSingleBuilder({'id': 77}));

        when(
          () => mockSupabase.from('sintomas_paciente'),
        ).thenAnswer((_) => qbSintomasPaciente);
        when(
          () => qbSintomasPaciente.insert(any()),
        ).thenAnswer((_) => FakeAwaitableFilterBuilder<dynamic>([]));

        await repository.registrarSeguimientoClinico(
          idPaciente: 10,
          idTratamientoPaciente: 100,
          dosisOmitidas: 2,
          idsSintomas: [1, 3],
        );

        verify(() => qbSeguimiento.insert(any())).called(1);
        verify(() => qbSintomasPaciente.insert(any())).called(1);
      },
    );
  });
}
