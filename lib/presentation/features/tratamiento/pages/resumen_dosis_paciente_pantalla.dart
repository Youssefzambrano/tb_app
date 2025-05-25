import 'package:flutter/material.dart';

class ResumenDosisPacientePantalla extends StatelessWidget {
  final int totalDosis;
  final int dosisTomadas;
  final String faseActual;
  final String dosisDelDia;

  const ResumenDosisPacientePantalla({
    Key? key,
    this.totalDosis = 56,
    this.dosisTomadas = 42,
    this.faseActual = 'Intensiva',
    this.dosisDelDia = 'Tomada',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progreso = dosisTomadas / totalDosis;
    final DateTime ultimaDosisFecha = DateTime.now().subtract(
      const Duration(days: 1),
    );

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
          // Encabezado
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
                Text(
                  'Total de dosis tomadas',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$dosisTomadas',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: Colors.black,
                  ),
                ),
                Text(
                  'de $totalDosis dosis',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.95),
                    fontSize: 22,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 20),
                // Barra de progreso
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
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Manrope',
                    ),
                    children: [
                      TextSpan(
                        text: '${(progreso * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' del total de dosis completado'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      title: 'Última dosis',
                      subtitle:
                          '${ultimaDosisFecha.day}/${ultimaDosisFecha.month}/${ultimaDosisFecha.year}',
                      icon: Icons.calendar_today,
                    ),
                    _buildInfoCard(
                      title: 'Dosis del día',
                      subtitle: dosisDelDia,
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
                      subtitle: 'Isoniazida',
                      icon: Icons.medical_services,
                    ),
                    _buildInfoCard(
                      title: 'Fase actual',
                      subtitle: faseActual,
                      icon: Icons.verified,
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
