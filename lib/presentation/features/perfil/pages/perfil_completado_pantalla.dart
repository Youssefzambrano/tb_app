import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/iniciar_tratamiento_controller_helper.dart';

class PerfilCompletadoPantalla extends StatelessWidget {
  final String? nombreEnfermero;
  final String? mensajeAsignacion;

  const PerfilCompletadoPantalla({
    super.key,
    this.nombreEnfermero,
    this.mensajeAsignacion,
  });

  @override
  Widget build(BuildContext context) {
    final mensaje =
        mensajeAsignacion ??
        ((nombreEnfermero != null && nombreEnfermero!.trim().isNotEmpty)
            ? 'Te asignamos al enfermero(a): $nombreEnfermero. Ahora puedes continuar con tu tratamiento.'
            : 'Tu perfil fue creado correctamente. Pronto te asignaremos un enfermero.');

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
                  'Perfil Completado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      IniciarTratamientoController().iniciarTratamientoDesdeSesion(context);
                    },
                    child: const Text(
                      'Empezar',
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
