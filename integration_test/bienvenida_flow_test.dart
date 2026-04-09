import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tb_app/presentation/features/bienvenida/pages/bienvenida_pantalla.dart';
import 'package:tb_app/presentation/features/bienvenida/pages/mensaje_bienvenida_pantalla.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'flujo: bienvenida -> mensaje bienvenida -> ultima pagina con boton Comenzar',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: BienvenidaPantalla()));

      await tester.pumpAndSettle();

      expect(find.text('Comenzar'), findsOneWidget);

      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      expect(find.byType(MensajeBienvenidaPantalla), findsOneWidget);
      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Te acompaño paso a paso'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('¡Vamos a vencer la tuberculosis!'), findsOneWidget);
      expect(find.text('Comenzar'), findsOneWidget);
    },
  );
}
