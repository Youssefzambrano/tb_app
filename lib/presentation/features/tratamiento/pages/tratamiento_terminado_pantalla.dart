import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../inicio/pages/inicio_usuario_pantalla.dart';

class TratamientoTerminadoPantalla extends StatelessWidget {
  const TratamientoTerminadoPantalla({super.key});

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
                  'assets/images/evita_celebra.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Tratamiento Completado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '¡Felicitaciones! Has completado tu tratamiento contra la tuberculosis. Contacta a tu enfermero para el seguimiento final.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InicioUsuarioPantalla(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Finalizar',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
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
