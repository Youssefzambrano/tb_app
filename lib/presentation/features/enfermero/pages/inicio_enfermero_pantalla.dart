import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/enfermero_dashboard_controller.dart';
import '../../../controllers/session_controller.dart';
import '../../auth/pages/cambiar_contrasena_pantalla.dart';
import '../../legal/pages/terminos_condiciones_pantalla.dart';
import '../../perfil/pages/perfil_pantalla.dart';
import '../widgets/tarjeta_paciente_enfermero.dart';
import 'detalle_paciente_enfermero_pantalla.dart';

class InicioEnfermeroPantalla extends StatefulWidget {
  const InicioEnfermeroPantalla({super.key});

  @override
  State<InicioEnfermeroPantalla> createState() =>
      _InicioEnfermeroPantallaState();
}

class _InicioEnfermeroPantallaState extends State<InicioEnfermeroPantalla> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idEnfermero = SessionController().idUsuario;
      if (idEnfermero != null) {
        context
            .read<EnfermeroDashboardController>()
            .cargarPacientesAsignados(idEnfermero);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EnfermeroDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Panel Enfermero'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(controller),
          _buildSearchBar(controller),
          _buildFiltroChips(controller),
          Expanded(child: _buildContenido(controller)),
        ],
      ),
    );
  }

  // ─── Drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final session = SessionController();
    final initials = session.nombreUsuario.isNotEmpty
        ? session.nombreUsuario
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Enfermero',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 11,
                          ),
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
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilPantalla(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.lock_outline,
                  title: 'Cambiar contraseña',
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CambiarContrasenaPantalla(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TerminosCondicionesPantalla(),
                      ),
                    );
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
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
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
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: c),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }

  // ─── Header con métricas reales ───────────────────────────────────────────

  Widget _buildHeader(EnfermeroDashboardController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC3D9), Color(0xFF67BF63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _headerMetrica(
            icon: Icons.group_outlined,
            valor: '${controller.totalPacientes}',
            etiqueta: 'Pacientes',
          ),
          _headerMetrica(
            icon: Icons.medication_outlined,
            valor: '${controller.pacientesSinDosisHoy}',
            etiqueta: 'Sin dosis hoy',
            colorValor: controller.pacientesSinDosisHoy > 0
                ? Colors.red.shade200
                : Colors.white,
          ),
          _headerMetrica(
            icon: Icons.warning_amber_outlined,
            valor: '${controller.pacientesConAlerta}',
            etiqueta: 'Con alerta',
            colorValor: controller.pacientesConAlerta > 0
                ? Colors.orange.shade200
                : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _headerMetrica({
    required IconData icon,
    required String valor,
    required String etiqueta,
    Color colorValor = Colors.white,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorValor,
            fontFamily: 'Outfit',
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  // ─── Barra de búsqueda ────────────────────────────────────────────────────

  Widget _buildSearchBar(EnfermeroDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        onChanged: controller.setBusqueda,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o cédula...',
          hintStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF67BF63)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    controller.setBusqueda('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ─── Chips de filtro ──────────────────────────────────────────────────────

  Widget _buildFiltroChips(EnfermeroDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _chip(
            label: 'Todos',
            activo: controller.filtroDosis == FiltroDosis.todos,
            onTap: () => controller.setFiltroDosis(FiltroDosis.todos),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Sin dosis hoy',
            activo: controller.filtroDosis == FiltroDosis.sinDosisHoy,
            onTap: () => controller.setFiltroDosis(FiltroDosis.sinDosisHoy),
            colorActivo: Colors.red.shade400,
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Con alerta',
            activo: controller.filtroDosis == FiltroDosis.conAlerta,
            onTap: () => controller.setFiltroDosis(FiltroDosis.conAlerta),
            colorActivo: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool activo,
    required VoidCallback onTap,
    Color colorActivo = const Color(0xFF67BF63),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? colorActivo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? colorActivo : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  // ─── Contenido principal ──────────────────────────────────────────────────

  Widget _buildContenido(EnfermeroDashboardController controller) {
    if (controller.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(controller.error!, textAlign: TextAlign.center),
        ),
      );
    }

    final lista = controller.pacientesFiltrados;

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              controller.pacientes.isEmpty
                  ? 'No hay pacientes asignados.'
                  : 'Sin resultados para la búsqueda.',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final id = SessionController().idUsuario;
        if (id != null) await controller.cargarPacientesAsignados(id);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final paciente = lista[index];
          return TarjetaPacienteEnfermero(
            paciente: paciente,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetallePacienteEnfermeroPantalla(paciente: paciente),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
