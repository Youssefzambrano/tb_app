import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../perfil/pages/completar_perfil_pantalla.dart';

class ConfirmarCorreoPantalla extends StatefulWidget {
  final String nombre;
  const ConfirmarCorreoPantalla({required this.nombre, super.key});

  @override
  State<ConfirmarCorreoPantalla> createState() =>
      _ConfirmarCorreoPantallaState();
}

class _ConfirmarCorreoPantallaState extends State<ConfirmarCorreoPantalla> {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> _verificarConfirmacion() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');

    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales no disponibles.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null && user.emailConfirmedAt != null) {
        await _secureStorage.deleteAll();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CompletarPerfilPantalla(nombre: widget.nombre),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu correo aún no ha sido confirmado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reenviarCodigo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa tu bandeja de entrada y spam.'),
          backgroundColor: Color(0xFF67BF63),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo_app.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Te enviamos un enlace de confirmación a tu correo electrónico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verificarConfirmacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Ya confirmé el correo',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reenviarCodigo,
                child: const Text(
                  '¿No recibiste el correo? Revisa tu spam',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
