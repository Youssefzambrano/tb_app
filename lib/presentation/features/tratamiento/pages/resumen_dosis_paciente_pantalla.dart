import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/dashboard_peciente_controller.dart';
import '../../../viewmodels/dashboard_resumen_paciente.dart';

class ResumenDosisPacientePantalla extends StatelessWidget {
  const ResumenDosisPacientePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardPacienteController>(context);
    final resumen = controller.resumen;

    if (controller.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (resumen == null) {
      return const Scaffold(
        body: Center(child: Text('No hay datos disponibles')),
      );
    }

    final double progreso = resumen.dosisTotales > 0
        ? resumen.dosisTomadas / resumen.dosisTotales
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        title: const Text('Resumen de Dosis'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [Encabezado con resumen]
          _buildHeader(resumen, progreso),
          // [Contenido con detalles]
          _buildDetails(resumen),
        ],
      ),
    );
  }

  Widget _buildHeader(DashboardPacienteResumen resumen, double progreso) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8BC3D9), Color(0xFF67BF63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total de dosis tomadas',
            style: TextStyle(fontSize: 30, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 12),
          Text(
            '${resumen.dosisTomadas}',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          Text(
            'de ${resumen.dosisTotales} dosis',
            style: const TextStyle(fontSize: 22, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 14,
              backgroundColor: Colors.white24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progreso * 100).toStringAsFixed(1)}% del total de dosis completado',
            style: const TextStyle(fontSize: 18, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(DashboardPacienteResumen resumen) {
    final ultima = resumen.ultimaDosis;
    final ultimaStr = ultima != null
        ? '${ultima.day.toString().padLeft(2, '0')}/${ultima.month.toString().padLeft(2, '0')}/${ultima.year}'
        : 'Sin dosis';

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard(
                title: 'Última dosis',
                subtitle: ultimaStr,
                icon: Icons.calendar_today,
              ),
              _buildInfoCard(
                title: 'Dosis del día',
                subtitle: resumen.dosisDeHoyTomada ? 'Tomada' : 'Pendiente',
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard(
                title: 'Medicamento',
                subtitle: resumen.medicamentoActual,
                icon: Icons.medical_services,
              ),
              _buildInfoCard(
                title: 'Fase actual',
                subtitle: resumen.faseActual,
                icon: Icons.verified,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF67BF63), size: 30),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
