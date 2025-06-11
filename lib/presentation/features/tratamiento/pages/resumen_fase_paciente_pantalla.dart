import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/resumen_fase_controller.dart';

class ResumenFasePacientePantalla extends StatelessWidget {
  const ResumenFasePacientePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ResumenFaseController>(context);

    if (controller.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.resumen == null) {
      return const Scaffold(
        body: Center(child: Text('No hay datos disponibles')),
      );
    }

    final String fase = controller.resumen!.faseActual;
    final int completados = controller.diasCompletados;
    final int restantes = controller.diasRestantes;
    final String fechaInicio = controller.fechaInicio;
    final String fechaFin = controller.fechaFin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        title: const Text('Resumen de Fase'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con fase y duración
          Container(
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
                  'Actual',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fase,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: Colors.black,
                  ),
                ),
                Text(
                  'La duración es de ${completados + restantes} días',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.95),
                    fontSize: 22,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),

          // Detalle con tarjetas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      title: 'Completados',
                      subtitle: '$completados días',
                      icon: Icons.check_circle_outline,
                    ),
                    _buildInfoCard(
                      title: 'Restantes',
                      subtitle: '$restantes días',
                      icon: Icons.calendar_today,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      title: 'Fecha inicio',
                      subtitle: fechaInicio,
                      icon: Icons.flag,
                    ),
                    _buildInfoCard(
                      title: 'Fecha fin',
                      subtitle: fechaFin,
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
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
