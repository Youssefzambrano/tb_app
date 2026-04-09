import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_app/presentation/features/tratamiento/pages/fase_intensiva_terminada_pantalla.dart';

void main() {
  testWidgets(
    'renderiza correctamente la pantalla de fase intensiva terminada',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FaseIntensivaTerminadaPantalla()),
      );

      // Texto principal
      expect(find.text('¡Fase Intensiva Completada!'), findsOneWidget);

      // Texto secundario
      expect(
        find.textContaining('fase intensiva de tu tratamiento'),
        findsOneWidget,
      );

      // Botón
      expect(find.text('Continuar'), findsOneWidget);

      // Imagen
      expect(find.byType(Image), findsOneWidget);
    },
  );
}
