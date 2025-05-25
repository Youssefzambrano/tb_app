import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../inicio/pages/inicio_usuario_pantalla.dart';

class ExitoTomaPantalla extends StatelessWidget {
  const ExitoTomaPantalla({super.key});

  void _abrirChatYVolver(BuildContext context) {
    // Aquí puedes agregar la lógica para obtener el link de WhatsApp desde la base de datos
    // y abrirlo, por ejemplo usando url_launcher.
    //
    // Ejemplo comentado:
    // final whatsappLink = obtenerDesdeBaseDeDatos();
    // launchUrl(Uri.parse(whatsappLink));

    // Luego, volver a Inicio
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioUsaurioPantalla()),
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
                  'assets/images/evita_celebra.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Toma registrada!',
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
                  'Ya registraste la toma del día.\nRecuerda ahora enviar el video al personal de salud para completar el registro.',
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
                      _abrirChatYVolver(context);
                    },
                    child: const Text(
                      'Entendido',
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
