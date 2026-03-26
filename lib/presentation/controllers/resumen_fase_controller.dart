import 'package:flutter/material.dart';
import '../../domain/usecases/obtener_dashboard_paciente_usecase.dart';
import '../viewmodels/dashboard_resumen_paciente.dart';

class ResumenFaseController extends ChangeNotifier {
  final ObtenerDashboardPacienteUseCase useCase;

  ResumenFaseController({required this.useCase});

  DashboardPacienteResumen? _resumen;
  bool _cargando = false;
  String? _error;

  DashboardPacienteResumen? get resumen => _resumen;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarResumen(int idPaciente) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await useCase(idPaciente);
      _resumen = resultado;
    } catch (e) {
      _error = 'Error al obtener resumen de fase: $e';
      _resumen = null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  int get diasCompletados => _resumen?.diasCompletados ?? 0;

  int get diasRestantes => _resumen?.diasRestantes ?? 0;

  String get fechaInicio {
    final fecha = _resumen?.fechaInicio;
    if (_resumen?.faseActual == 'Continuación' &&
        (_resumen?.dosisTomadas ?? 0) < 57) {
      return 'Pendiente';
    }
    return fecha != null
        ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'
        : 'Pendiente';
  }

  String get fechaFin {
    return _resumen?.fechaFin != null
        ? '${_resumen!.fechaFin!.day.toString().padLeft(2, '0')}/${_resumen!.fechaFin!.month.toString().padLeft(2, '0')}/${_resumen!.fechaFin!.year}'
        : 'Pendiente';
  }
}
