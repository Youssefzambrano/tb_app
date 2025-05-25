import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../inicio/pages/inicio_usuario_pantalla.dart';

class ChequeoPositivoPantalla extends StatelessWidget {
  const ChequeoPositivoPantalla({super.key});

  void _volverAlInicio(BuildContext context) {
    // Aquí más adelante puedes incluir lógica para abrir WhatsApp u otro canal.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioUsaurioPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD580), // Naranja cálido y suave
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
                  '¡Gracias por tu respuesta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hemos notado que presentas síntomas.\nNo te preocupes, todo va a estar bien.\nAhora te pondrás en contacto con el personal de salud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _volverAlInicio(context);
                    },
                    child: const Text(
                      'Ir al inicio',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
