import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/session_controller.dart';
import '../../auth/pages/cambiar_contrasena_pantalla.dart';
import '../../legal/pages/tratamiento_datos_pantalla.dart';
import 'editar_perfil_pantalla.dart';

class PerfilPantalla extends StatelessWidget {
  const PerfilPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionController();
    final nombre = session.nombreUsuario;
    final correo = session.correoUsuario;
    final initials = nombre.isNotEmpty
        ? nombre.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF67BF63),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correo,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Opciones de perfil
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Editar Perfil',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditarPerfilPantalla(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.lock,
              title: 'Cambiar Contraseña',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CambiarContrasenaPantalla(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.privacy_tip,
              title: 'Política y Tratamiento de Datos',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TratamientoDatosPantalla(),
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF67BF63),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
