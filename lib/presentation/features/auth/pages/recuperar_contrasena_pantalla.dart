import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/datasources/remote/supabase/auth_supabase_service.dart';

class RecuperarContrasenaPantalla extends StatefulWidget {
  const RecuperarContrasenaPantalla({super.key});

  @override
  State<RecuperarContrasenaPantalla> createState() =>
      _RecuperarContrasenaPantallaState();
}

class _RecuperarContrasenaPantallaState
    extends State<RecuperarContrasenaPantalla> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    final email = _emailController.text.trim();

    try {
      await AuthSupabaseService().resetPassword(email);
      HapticFeedback.lightImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Te enviamos una contraseña temporal al correo. Úsala para ingresar y luego cámbiala desde tu perfil.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 6),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo_app.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recupera tu contraseña',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingresa tu correo electrónico registrado. Te enviaremos una contraseña temporal para que puedas ingresar y luego cambiarla desde tu perfil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _sendRecoveryEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 104, 191, 99),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Enviar instrucciones',
                          style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Volver',
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
