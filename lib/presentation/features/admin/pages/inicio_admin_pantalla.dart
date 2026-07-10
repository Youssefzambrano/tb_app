import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/session_controller.dart';
import '../../auth/pages/cambiar_contrasena_pantalla.dart';
import '../../legal/pages/terminos_condiciones_pantalla.dart';
import '../../perfil/pages/perfil_pantalla.dart';
import 'gestionar_asignaciones_pantalla.dart';
import 'gestionar_enfermeros_pantalla.dart';
import 'gestionar_pacientes_pantalla.dart';

class InicioAdminPantalla extends StatelessWidget {
  const InicioAdminPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildOpcionCard(
                context,
                icon: Icons.medical_services_outlined,
                titulo: 'Enfermeros',
                descripcion: 'Gestionar enfermeros del sistema',
                color: const Color(0xFF67BF63),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GestionarEnfermerosPantalla(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOpcionCard(
                context,
                icon: Icons.person_outlined,
                titulo: 'Pacientes',
                descripcion: 'Gestionar pacientes del sistema',
                color: const Color(0xFF8BC3D9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GestionarPacientesPantalla(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOpcionCard(
                context,
                icon: Icons.assignment_ind_outlined,
                titulo: 'Asignaciones',
                descripcion: 'Asignar pacientes a enfermeros',
                color: const Color(0xFF9B7ED4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GestionarAsignacionesPantalla(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final session = SessionController();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF67BF63), Color(0xFF8BC3D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, ${session.nombreUsuario}',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Administrador del sistema',
                  style: TextStyle(
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
    );
  }

  Widget _buildOpcionCard(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final session = SessionController();
    final initials = session.nombreUsuario.isNotEmpty
        ? session.nombreUsuario.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF67BF63), Color(0xFF8BC3D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF67BF63),
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.nombreUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.correoUsuario,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Manrope',
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Administrador',
                          style: TextStyle(color: Colors.white, fontFamily: 'Manrope', fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(
                  icon: Icons.person_outline,
                  title: 'Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilPantalla()));
                  },
                ),
                _drawerItem(
                  icon: Icons.lock_outline,
                  title: 'Cambiar contraseña',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CambiarContrasenaPantalla()));
                  },
                ),
                _drawerItem(
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminosCondicionesPantalla()));
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                _drawerItem(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  color: Colors.red.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    SessionController().cerrarSesionYRedirigir(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? Colors.black87;
    return ListTile(
      leading: Icon(icon, color: c, size: 24),
      title: Text(title, style: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: c)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
