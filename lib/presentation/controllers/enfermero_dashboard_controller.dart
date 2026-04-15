import 'package:flutter/material.dart';
import '../../domain/entities/enfermero_resumen_paciente.dart';
import '../../domain/entities/sintoma.dart';
import '../../domain/usecases/obtener_catalogo_sintomas_usecase.dart';
import '../../domain/usecases/obtener_dashboard_enfermero_usecase.dart';
import '../../domain/usecases/registrar_seguimiento_clinico_usecase.dart';
import '../../domain/usecases/validar_toma_paciente_enfermero_usecase.dart';

enum FiltroDosis { todos, sinDosisHoy, conAlerta }

class EnfermeroDashboardController extends ChangeNotifier {
  final ObtenerDashboardEnfermeroUseCase useCase;
  final ValidarTomaPacienteEnfermeroUseCase validarTomaUseCase;
  final RegistrarSeguimientoClinicoUseCase registrarSeguimientoUseCase;
  final ObtenerCatalogoSintomasUseCase obtenerCatalogoSintomasUseCase;

  EnfermeroDashboardController({
    required this.useCase,
    required this.validarTomaUseCase,
    required this.registrarSeguimientoUseCase,
    required this.obtenerCatalogoSintomasUseCase,
  });

  bool _cargando = false;
  bool _guardando = false;
  String? _error;
  List<EnfermeroResumenPaciente> _pacientes = [];
  List<Sintoma> _sintomasCatalogo = [];

  String _busqueda = '';
  FiltroDosis _filtroDosis = FiltroDosis.todos;

  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;
  List<EnfermeroResumenPaciente> get pacientes => _pacientes;
  List<Sintoma> get sintomasCatalogo => _sintomasCatalogo;
  String get busqueda => _busqueda;
  FiltroDosis get filtroDosis => _filtroDosis;

  int get totalPacientes => _pacientes.length;
  int get pacientesConAlerta => _pacientes.where((p) => p.tieneAlerta).length;
  int get pacientesSinDosisHoy =>
      _pacientes.where((p) => !p.dosisHoyTomada).length;

  List<EnfermeroResumenPaciente> get pacientesFiltrados {
    var lista = _pacientes;

    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((p) {
        return p.nombrePaciente.toLowerCase().contains(q) ||
            p.numeroDocumento.toLowerCase().contains(q);
      }).toList();
    }

    switch (_filtroDosis) {
      case FiltroDosis.sinDosisHoy:
        lista = lista.where((p) => !p.dosisHoyTomada).toList();
        break;
      case FiltroDosis.conAlerta:
        lista = lista.where((p) => p.tieneAlerta).toList();
        break;
      case FiltroDosis.todos:
        break;
    }

    return lista;
  }

  void setBusqueda(String valor) {
    _busqueda = valor;
    notifyListeners();
  }

  void setFiltroDosis(FiltroDosis filtro) {
    _filtroDosis = filtro;
    notifyListeners();
  }

  Future<void> cargarPacientesAsignados(int idEnfermero) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _pacientes = await useCase(idEnfermero);
    } catch (e) {
      _error = 'No se pudo cargar el dashboard: $e';
      _pacientes = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCatalogoSintomas() async {
    try {
      _sintomasCatalogo = await obtenerCatalogoSintomasUseCase();
      notifyListeners();
    } catch (_) {
      // Fallback silencioso: la pantalla de seguimiento mostrara estado vacio.
      _sintomasCatalogo = [];
      notifyListeners();
    }
  }

  Future<void> validarTomaPaciente({
    required int idEnfermero,
    required int idPaciente,
    required int idTratamientoPaciente,
    required String estado,
  }) async {
    _guardando = true;
    notifyListeners();
    try {
      await validarTomaUseCase(
        idPaciente: idPaciente,
        idTratamientoPaciente: idTratamientoPaciente,
        estado: estado,
      );
      await cargarPacientesAsignados(idEnfermero);
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<void> registrarSeguimientoClinico({
    required int idEnfermero,
    required int idPaciente,
    required int idTratamientoPaciente,
    required int dosisOmitidas,
    required List<int> idsSintomas,
  }) async {
    _guardando = true;
    notifyListeners();
    try {
      await registrarSeguimientoUseCase(
        idPaciente: idPaciente,
        idTratamientoPaciente: idTratamientoPaciente,
        dosisOmitidas: dosisOmitidas,
        idsSintomas: idsSintomas,
      );
      await cargarPacientesAsignados(idEnfermero);
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
