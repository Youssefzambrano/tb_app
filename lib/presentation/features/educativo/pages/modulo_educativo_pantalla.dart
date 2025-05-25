import 'package:flutter/material.dart';

class ModuloEducativoPantalla extends StatelessWidget {
  const ModuloEducativoPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Módulo Educativo'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aprende sobre tu tratamiento',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _cardTema(
                context,
                titulo: '¿Qué es la tuberculosis?',
                subtitulo: 'Descubre cómo se origina y se trata.',
                icono: Icons.coronavirus,
              ),
              _cardTema(
                context,
                titulo: 'Fases del tratamiento',
                subtitulo: 'Entiende las etapas que recorrerás.',
                icono: Icons.timeline,
              ),
              _cardTema(
                context,
                titulo: 'Importancia de la adherencia',
                subtitulo: 'Por qué es clave no saltarte ninguna dosis.',
                icono: Icons.medical_services,
              ),
              _cardTema(
                context,
                titulo: 'Mitos y verdades',
                subtitulo: 'Aclara tus dudas más comunes.',
                icono: Icons.fact_check,
              ),
              _cardTema(
                context,
                titulo: 'Cuidados en casa',
                subtitulo: 'Qué hacer y qué evitar mientras te recuperas.',
                icono: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardTema(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
    required IconData icono,
  }) {
    return InkWell(
      onTap: () {
        // Navegar al detalle del tema educativo
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF67BF63),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, size: 36, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
