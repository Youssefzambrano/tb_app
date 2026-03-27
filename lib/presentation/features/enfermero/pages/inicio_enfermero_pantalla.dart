import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/enfermero_dashboard_controller.dart';
import '../../../controllers/session_controller.dart';
import '../widgets/tarjeta_paciente_enfermero.dart';
import 'detalle_paciente_enfermero_pantalla.dart';

class InicioEnfermeroPantalla extends StatefulWidget {
  const InicioEnfermeroPantalla({super.key});

  @override
  State<InicioEnfermeroPantalla> createState() => _InicioEnfermeroPantallaState();
}

class _InicioEnfermeroPantallaState extends State<InicioEnfermeroPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idEnfermero = SessionController().idUsuario;
      if (idEnfermero != null) {
        context.read<EnfermeroDashboardController>().cargarPacientesAsignados(
          idEnfermero,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EnfermeroDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Enfermero'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _header(controller),
          Expanded(child: _contenido(controller)),
        ],
      ),
    );
  }

  Widget _header(EnfermeroDashboardController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC3D9), Color(0xFF67BF63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _headerItem('Pacientes', '${controller.totalPacientes}'),
          _headerItem('Alertas', '${controller.pacientesConAlerta}'),
        ],
      ),
    );
  }

  Widget _headerItem(String titulo, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(titulo, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  Widget _contenido(EnfermeroDashboardController controller) {
    if (controller.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(controller.error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (controller.pacientes.isEmpty) {
      return const Center(
        child: Text('No hay pacientes asignados para este enfermero.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final id = SessionController().idUsuario;
        if (id != null) {
          await controller.cargarPacientesAsignados(id);
        }
      },
      child: ListView.builder(
        itemCount: controller.pacientes.length,
        itemBuilder: (context, index) {
          final paciente = controller.pacientes[index];
          return TarjetaPacienteEnfermero(
            paciente: paciente,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => DetallePacienteEnfermeroPantalla(paciente: paciente),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
