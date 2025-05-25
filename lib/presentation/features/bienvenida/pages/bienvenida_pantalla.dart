import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/pages/ingresar_pantalla.dart';
import 'mensaje_bienvenida_pantalla.dart';

class bienvenida_pantalla extends StatelessWidget {
  const bienvenida_pantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo_app.png',
                        width: 400,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 104, 191, 99),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Navegar a la pantalla mensaje_bienvenida
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MensajeBienvenidaPantalla(),
                          ),
                        );
                      },
                      child: const Text(
                        'Comenzar',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      // Navegar a la pantalla de ingreso (IngresarPantalla)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IngresarPantalla(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        children: [
                          TextSpan(text: '¿Ya estás registrado? '),
                          TextSpan(
                            text: 'Ingresar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
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
