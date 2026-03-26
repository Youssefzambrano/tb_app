import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/cargando_logo.dart';
import '../features/bienvenida/pages/bienvenida_pantalla.dart';
import '../features/inicio/pages/inicio_usuario_pantalla.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🟡 SplashScreen iniciado...');
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Pausa mínima para que la sesión de Supabase se restaure del storage local
    await Future.delayed(const Duration(milliseconds: 500));

    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('🔍 Sesión: ${session != null ? "activa (${session.user.email})" : "ninguna"}');

    if (!mounted) return;
    if (session != null) {
      _navigateToInicio();
    } else {
      _navigateToBienvenida();
    }
  }

  void _navigateToInicio() {
    debugPrint('🚀 Navegando a InicioUsuarioPantalla');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioUsuarioPantalla()),
    );
  }

  void _navigateToBienvenida() {
    debugPrint('🚀 Navegando a BienvenidaPantalla');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BienvenidaPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CargandoLogo());
  }
}
