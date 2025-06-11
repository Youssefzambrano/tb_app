import 'package:flutter/material.dart';
import '../../domain/usecases/obtener_dashboard_paciente_usecase.dart';
import '../viewmodels/dashboard_resumen_paciente.dart';

class DashboardPacienteController extends ChangeNotifier {
  final ObtenerDashboardPacienteUseCase useCase;

  DashboardPacienteController({required this.useCase});

  DashboardPacienteResumen? _resumen;
  DashboardPacienteResumen? get resumen => _resumen;

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _error;
  String? get error => _error;

  Future<void> cargarResumen(int idPaciente) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    debugPrint('📥 Cargando resumen para paciente con ID $idPaciente');

    try {
      final resultado = await useCase(idPaciente);
      debugPrint(
        '✅ Resumen recibido: ${resultado.faseActual}, '
        'Dosis: ${resultado.dosisTomadas}/${resultado.dosisTotales}',
      );
      _resumen = resultado;
    } catch (e) {
      _error = 'Error al cargar el resumen: $e';
      _resumen = null;
      debugPrint('❌ Error en cargarResumen: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _resumen = null;
    _error = null;
    notifyListeners();
  }
}
