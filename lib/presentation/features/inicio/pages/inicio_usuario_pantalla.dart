import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/usuario_model.dart';
import '../../../controllers/dashboard_peciente_controller.dart';
import '../../tratamiento/pages/registrar_toma_pantalla.dart';
import '../../autochequeo/pages/modulo_autochequeo_pantalla.dart';
import '../../tratamiento/pages/resumen_dosis_paciente_pantalla.dart';
import '../../tratamiento/pages/resumen_fase_paciente_pantalla.dart';
import '../../perfil/pages/perfil_pantalla.dart';
import '../../legal/pages/terminos_condiciones_pantalla.dart';
import '../../educativo/modulo_educativo_pantalla.dart';
import '../../../controllers/session_controller.dart';
import '../../../../services/notificaciones_service.dart';

class InicioUsuarioPantalla extends StatefulWidget {
  const InicioUsuarioPantalla({super.key});

  @override
  State<InicioUsuarioPantalla> createState() => _InicioUsuarioPantallaState();
}

class _InicioUsuarioPantallaState extends State<InicioUsuarioPantalla> {
  bool _faltaDosisHoy = false;
  bool _faltaChequeoSemana = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final session = SessionController();

    // Si viene del splash con sesión activa pero sin usuario en memoria, cargarlo
    if (session.idUsuario == null) {
      final email = Supabase.instance.client.auth.currentUser?.email;
      debugPrint('📥 Cargando usuario desde BD (sesión restaurada)... email=$email');
      if (email != null) {
        try {
          final data = await Supabase.instance.client
              .from('usuario')
              .select()
              .eq('correo_electronico', email)
              .single();
          final usuario = UsuarioModel.fromMap(data);
          await session.inicializarUsuarioActual(usuario);
          debugPrint('✅ Usuario cargado: ID=${usuario.id}');
        } catch (e) {
          debugPrint('❌ Error al cargar usuario: $e');
        }
      }
    }

    final id = session.idUsuario;
    debugPrint('🧠 ID del usuario en sesión: $id');
    if (id != null && mounted) {
      final controller = Provider.of<DashboardPacienteController>(
        context,
        listen: false,
      );
      controller.cargarResumen(id);
    }

    _verificarPendientes();
    NotificacionesService.inicializar().then((_) {
      NotificacionesService.programarNotificaciones();
    }).catchError((e) {
      debugPrint('⚠️ Error al inicializar notificaciones: $e');
    });
  }

  Future<void> _verificarPendientes() async {
    final idUsuario = SessionController().idUsuario;
    if (idUsuario == null) return;

    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    final hoyStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1));
    final semanaStr = '${inicioSemana.year}-${inicioSemana.month.toString().padLeft(2, '0')}-${inicioSemana.day.toString().padLeft(2, '0')}';

    // Obtener tratamiento activo
    final tratamiento = await supabase
        .from('tratamiento_paciente')
        .select('id')
        .eq('id_paciente', idUsuario)
        .eq('estado', 'En curso')
        .maybeSingle();

    if (tratamiento == null) return;
    final idTratamiento = tratamiento['id'] as int;

    // ¿Tomó la dosis hoy?
    final dosisHoy = await supabase
        .from('dosis')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento)
        .eq('estado', 'Tomada')
        .gte('fecha_hora_toma', '${hoyStr}T00:00:00')
        .limit(1)
        .maybeSingle();

    // ¿Hizo autochequeo esta semana?
    final chequeoSemana = await supabase
        .from('seguimiento_paciente')
        .select('id')
        .eq('id_tratamiento_paciente', idTratamiento)
        .gte('fecha_reporte', semanaStr)
        .limit(1)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _faltaDosisHoy = dosisHoy == null;
        _faltaChequeoSemana = chequeoSemana == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const Text('Mi tratamiento'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatePanel(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/evita_saluda.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Acá puedes gestionar tu tratamiento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePanel(BuildContext context) {
    final controller = Provider.of<DashboardPacienteController>(context);
    final resumen = controller.resumen;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF67BF63), Color(0xFF8BC3D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Panel de Estado Actual',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (controller.cargando)
              const CircularProgressIndicator()
            else if (resumen == null)
              const Text('No hay datos disponibles')
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stateItem(
                    context,
                    title: 'Dosis',
                    value: '${resumen.dosisTomadas}/${resumen.dosisTotales}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ResumenDosisPacientePantalla(),
                        ),
                      );
                    },
                  ),
                  _stateItem(
                    context,
                    title: 'Fase',
                    value: resumen.faseActual,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ResumenFasePacientePantalla(),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _stateItem(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _serviceItem(
            context,
            title: 'Registrar Nueva Toma',
            icon: Icons.medication,
            badge: _faltaDosisHoy,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrarTomaPantalla(),
                ),
              ).then((_) => _verificarPendientes());
            },
          ),
          const SizedBox(height: 12),
          _serviceItem(
            context,
            title: 'Módulo de autochequeo',
            icon: Icons.monitor_heart,
            badge: _faltaChequeoSemana,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModuloAutochequeoPantalla(),
                ),
              ).then((_) => _verificarPendientes());
            },
          ),
          const SizedBox(height: 12),
          _serviceItem(
            context,
            title: 'Módulo Educativo',
            icon: Icons.menu_book,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModuloEducativoPantalla(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _serviceItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF67BF63),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(icon, size: 40, color: Colors.white),
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
              ],
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 0,
            right: 4,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
