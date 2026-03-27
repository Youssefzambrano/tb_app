import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/enfermero_resumen_paciente.dart';
import '../../../controllers/enfermero_dashboard_controller.dart';
import '../../../controllers/session_controller.dart';

class DetallePacienteEnfermeroPantalla extends StatefulWidget {
  final EnfermeroResumenPaciente paciente;

  const DetallePacienteEnfermeroPantalla({super.key, required this.paciente});

  @override
  State<DetallePacienteEnfermeroPantalla> createState() =>
      _DetallePacienteEnfermeroPantallaState();
}

class _DetallePacienteEnfermeroPantallaState
    extends State<DetallePacienteEnfermeroPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnfermeroDashboardController>().cargarCatalogoSintomas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EnfermeroDashboardController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        title: const Text('Detalle del Paciente'),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard(
                title: widget.paciente.nombrePaciente,
                subtitle: widget.paciente.correoPaciente,
              ),
              const SizedBox(height: 12),
              _metricCard(
                'Estado tratamiento',
                widget.paciente.estadoTratamiento,
              ),
              _metricCard('Fase actual', widget.paciente.faseActual),
              _metricCard(
                'Dosis tomadas',
                '${widget.paciente.dosisTomadas}/${widget.paciente.dosisTotales}',
              ),
              _metricCard(
                'Tomo dosis hoy',
                widget.paciente.dosisHoyTomada ? 'Si' : 'No',
              ),
              _metricCard(
                'Reporto sintomas hoy',
                widget.paciente.reportoSintomasHoy ? 'Si' : 'No',
              ),
              _metricCard(
                'Prioridad clinica',
                'Nivel ${widget.paciente.prioridadClinica}',
              ),
              const SizedBox(height: 16),
              _accionesClinicas(context),
            ],
          ),
          if (controller.guardando)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _accionesClinicas(BuildContext context) {
    final tieneTratamiento = widget.paciente.idTratamiento != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: tieneTratamiento ? () => _dialogoValidarToma(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF67BF63),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.medication_outlined),
          label: const Text('Validar toma de hoy'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed:
              tieneTratamiento ? () => _dialogoRegistrarSeguimiento(context) : null,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.assignment_turned_in_outlined),
          label: const Text('Registrar seguimiento clinico'),
        ),
        if (!tieneTratamiento)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Este paciente no tiene tratamiento activo.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
      ],
    );
  }

  Future<void> _dialogoValidarToma(BuildContext context) async {
    String estado = 'Tomada';

    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
                  title: const Text('Validar toma'),
                  content: StatefulBuilder(
                    builder:
                  (ctx, setStateDialog) => DropdownButtonFormField<String>(
                    initialValue: estado,
                    items: const [
                      DropdownMenuItem(value: 'Tomada', child: Text('Tomada')),
                      DropdownMenuItem(value: 'Omitida', child: Text('Omitida')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setStateDialog(() => estado = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Estado de la dosis',
                    ),
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (confirmado != true) return;
    final idEnfermero = SessionController().idUsuario;
    final idTratamiento = widget.paciente.idTratamiento;
    if (idEnfermero == null || idTratamiento == null) return;

    try {
      if (!context.mounted) return;
      await context.read<EnfermeroDashboardController>().validarTomaPaciente(
        idEnfermero: idEnfermero,
        idPaciente: widget.paciente.idPaciente,
        idTratamientoPaciente: idTratamiento,
        estado: estado,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma validada correctamente.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo validar la toma: $e')),
      );
    }
  }

  Future<void> _dialogoRegistrarSeguimiento(BuildContext context) async {
    final controller = context.read<EnfermeroDashboardController>();
    final dosisOmitidasController = TextEditingController(text: '0');
    final seleccionados = <int>{};

    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setStateDialog) => AlertDialog(
                  title: const Text('Registrar seguimiento'),
                  content: SizedBox(
                    width: 420,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: dosisOmitidasController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dosis omitidas',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Sintomas reportados',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.sintomasCatalogo.map((sintoma) {
                            final marcado = seleccionados.contains(sintoma.id);
                            return CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: marcado,
                              title: Text(sintoma.nombre),
                              onChanged: (value) {
                                setStateDialog(() {
                                  if (value == true) {
                                    seleccionados.add(sintoma.id);
                                  } else {
                                    seleccionados.remove(sintoma.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );

    if (confirmado != true) return;

    final idEnfermero = SessionController().idUsuario;
    final idTratamiento = widget.paciente.idTratamiento;
    if (idEnfermero == null || idTratamiento == null) return;

    final dosisOmitidas = int.tryParse(dosisOmitidasController.text.trim()) ?? 0;

    try {
      await controller.registrarSeguimientoClinico(
        idEnfermero: idEnfermero,
        idPaciente: widget.paciente.idPaciente,
        idTratamientoPaciente: idTratamiento,
        dosisOmitidas: dosisOmitidas,
        idsSintomas: seleccionados.toList(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento registrado correctamente.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar seguimiento: $e')),
      );
    } finally {
      dosisOmitidasController.dispose();
    }
  }

  Widget _infoCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
