import 'package:flutter/material.dart';
import 'exito_toma_pantalla.dart';

class RegistrarTomaPantalla extends StatelessWidget {
  const RegistrarTomaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Toma'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildEvitaSection(),
              const SizedBox(height: 24),
              _buildTomaInfo(),
              const SizedBox(height: 24),
              _buildRegistrarButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvitaSection() {
    return Column(
      children: [
        Image.asset('assets/images/evita_feliz.png', width: 150, height: 150),
        const SizedBox(height: 12),
        const Text(
          'Estás a punto de registrar una nueva toma',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTomaInfo() {
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8BC3D9), Color(0xFF67BF63)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _infoItem('Fase', '1'),
            const SizedBox(height: 12),
            _infoItem('Medicamento', 'Evitarol 500mg'),
            const SizedBox(height: 12),
            _infoItem('Fecha', '28/04/2025'),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrarButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF67BF63),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExitoTomaPantalla(),
              ),
            );
          },
          child: const Text(
            'Registrar Toma',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
