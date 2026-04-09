import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/auth/pages/confirmar_correo_pantalla.dart';

void main() {
  testWidgets('renderiza correctamente la pantalla confirmar correo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConfirmarCorreoPantalla(nombre: 'Kevin')),
    );

    expect(find.textContaining('Te enviamos un enlace'), findsOneWidget);
    expect(find.text('Ya confirmé el correo'), findsOneWidget);
    expect(find.textContaining('¿No recibiste el correo?'), findsOneWidget);
  });

  testWidgets('botón reenviar muestra snackbar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConfirmarCorreoPantalla(nombre: 'Kevin')),
    );

    await tester.tap(find.textContaining('¿No recibiste el correo?'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Revisa tu bandeja'), findsOneWidget);
  });
}
