import 'package:flutter/material.dart';

class TerminosCondicionesPantalla extends StatelessWidget {
  const TerminosCondicionesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Términos y Condiciones de Uso',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Phasellus imperdiet, nulla et dictum interdum, nisi lorem egestas odio, '
                'vitae scelerisque enim ligula venenatis dolor. Maecenas nisl est, ultrices nec congue eget, '
                'auctor vitae massa. Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Suspendisse euismod, nisi vel consectetur euismod, nisl nunc.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
