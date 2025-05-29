import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    debugPrint('🟡 SplashScreen iniciado...');
    _checkSession();
  }

  Future<void> _checkSession() async {
    final client = Supabase.instance.client;
    debugPrint('🔍 Verificando sesión actual...');

    // Si ya hay una sesión activa
    if (client.auth.currentSession != null) {
      final email = client.auth.currentUser?.email;
      debugPrint('📦 Supabase session: ${client.auth.currentSession}');
      debugPrint('✅ Sesión activa encontrada. Usuario: $email');
      _navigateToInicio();
      return;
    }

    // Si no hay sesión, intentar login con storage seguro
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');

    debugPrint('🔐 Credenciales desde storage: $email, $password');

    if (email != null && password != null) {
      try {
        await client.auth.signInWithPassword(email: email, password: password);
        debugPrint('✅ Sesión restaurada exitosamente con login automático');
        _navigateToInicio();
        return;
      } catch (e) {
        debugPrint('❌ Auto login falló: $e');
      }
    }

    // Si no hay sesión ni credenciales
    debugPrint('🔁 Sin sesión ni credenciales, navegando a bienvenida');
    _navigateToBienvenida();
  }

  void _navigateToInicio() {
    debugPrint('🚀 Navegando a InicioUsuarioPantalla');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioUsuarioPantalla()),
      );
    });
  }

  void _navigateToBienvenida() {
    debugPrint('🚀 Navegando a BienvenidaPantalla');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BienvenidaPantalla()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CargandoLogo());
  }
}
