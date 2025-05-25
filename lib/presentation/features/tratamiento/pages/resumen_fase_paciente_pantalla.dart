import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumenFasePacientePantalla extends StatefulWidget {
  final String faseActual;
  final int duracionDias;
  final int diasRestantes;

  const ResumenFasePacientePantalla({
    super.key,
    this.faseActual = 'Fase intensiva',
    this.duracionDias = 56,
    this.diasRestantes = 14,
  });

  @override
  State<ResumenFasePacientePantalla> createState() =>
      _ResumenFasePacientePantallaState();
}

class _ResumenFasePacientePantallaState
    extends State<ResumenFasePacientePantalla> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final DateTime fechaInicio = DateTime.now().subtract(
      Duration(days: widget.duracionDias - widget.diasRestantes),
    );
    final DateTime fechaFin = DateTime.now().add(
      Duration(days: widget.diasRestantes),
    );
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    final List<Map<String, dynamic>> fases = [
      {
        'estado': 'Actual',
        'fase': 'Fase intensiva',
        'completados': widget.duracionDias - widget.diasRestantes,
        'restantes': widget.diasRestantes,
        'fechaInicio': formatter.format(fechaInicio),
        'fechaFin': formatter.format(fechaFin),
      },
      {
        'estado': 'Pendiente',
        'fase': 'Fase continuación',
        'completados': 0,
        'restantes': 112,
        'fechaInicio': 'Pendiente',
        'fechaFin': 'Pendiente',
      },
    ];

    final fase = fases[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        title: const Text('Resumen de Fase'),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF67BF63),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Intensiva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Continuación',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  fase['estado'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fase['fase'],
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: Colors.black,
                  ),
                ),
                Text(
                  'La duración es de ${fase['completados'] + fase['restantes']} días',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.95),
                    fontSize: 22,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      title: 'Completados',
                      subtitle: '${fase['completados']} días',
                      icon: Icons.check_circle_outline,
                    ),
                    _buildInfoCard(
                      title: 'Restantes',
                      subtitle: '${fase['restantes']} días',
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
                      subtitle: fase['fechaInicio'],
                      icon: Icons.flag,
                    ),
                    _buildInfoCard(
                      title: 'Fecha fin',
                      subtitle: fase['fechaFin'],
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
