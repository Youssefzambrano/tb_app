import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Carga el JSON educativo desde los assets
Future<Map<String, dynamic>> cargarModuloEducativo() async {
  final String data = await rootBundle.loadString(
    'assets/modulo_educativo.json',
  );
  return json.decode(data);
}
