import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../perfil/pages/perfil_pantalla.dart';
import '../../legal/pages/terminos_condiciones_pantalla.dart';

class InicioEnfermeroPantalla extends StatelessWidget {
  const InicioEnfermeroPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        title: const Text('Gestión de Pacientes'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/evita_saluda.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hola, acá puedes gestionar a tus pacientes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dashboardCard(
                    title: 'Pacientes',
                    subtitle: '12 activos',
                    icon: Icons.group,
                    color: const Color(0xFF8BC3D9),
                  ),
                  _dashboardCard(
                    title: 'Dosis hoy',
                    subtitle: '7/12 tomadas',
                    icon: Icons.medication,
                    color: const Color(0xFF67BF63),
                  ),
                  _dashboardCard(
                    title: 'Síntomas',
                    subtitle: '3 reportes',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFFFD54F),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _actionShortcut(
                icon: Icons.sick,
                label: 'Ver todos los síntomas',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigator.push(...);
                },
              ),
              const SizedBox(height: 16),
              _actionShortcut(
                icon: Icons.pending_actions,
                label: 'Ver pacientes con dosis pendientes',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigator.push(...);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionShortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF67BF63)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/evita_feliz.png'),
                ),
                SizedBox(height: 8),
                Text(
                  'Nombre del profesional',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Outfit',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilPantalla()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Términos y Condiciones'),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TerminosCondicionesPantalla(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
