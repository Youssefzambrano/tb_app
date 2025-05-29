import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../inicio/pages/inicio_usuario_pantalla.dart';

class ChequeoNegativoPantalla extends StatelessWidget {
  const ChequeoNegativoPantalla({super.key});

  void _volverAlInicio(BuildContext context) {
    // Lógica para volver al inicio
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioUsuarioPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67BF63),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/evita_feliz.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Sin síntomas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sigue así, tu compromiso es fundamental para tu recuperación. Recuerda que cada día cuenta y vas por buen camino.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _volverAlInicio(context);
                    },
                    child: const Text(
                      'Volver al inicio',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF67BF63),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
