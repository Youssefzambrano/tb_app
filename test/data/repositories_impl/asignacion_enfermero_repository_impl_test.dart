import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/data/repositories_impl/asignacion_enfermero_repository_impl.dart';

void main() {
  group('seleccionarEnfermeroBalanceado', () {
    test(
      'distribuye de forma balanceada 20 pacientes entre 3 enfermeros (diferencia <= 1)',
      () {
        final random = Random(42);
        final cargas = <int, int>{1: 0, 2: 0, 3: 0};

        for (var i = 0; i < 20; i++) {
          final idSeleccionado = seleccionarEnfermeroBalanceado(
            cargas:
                cargas.entries
                    .map(
                      (e) => {
                        'id_enfermero': e.key,
                        'total': e.value,
                      },
                    )
                    .toList(),
            random: random,
          );

          cargas[idSeleccionado] = (cargas[idSeleccionado] ?? 0) + 1;
        }

        final valores = cargas.values.toList()..sort();
        final diferencia = valores.last - valores.first;

        expect(diferencia <= 1, isTrue);
        expect(valores.reduce((a, b) => a + b), 20);
      },
    );

    test('lanza error si no hay enfermeros disponibles', () {
      expect(
        () => seleccionarEnfermeroBalanceado(cargas: [], random: Random(1)),
        throwsA(isA<StateError>()),
      );
    });
  });
}
