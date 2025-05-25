import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendRecoveryEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      debugPrint('Enviando instrucciones de recuperación a: $email');
      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se enviaron las instrucciones de recuperación al correo.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Aquí podrías llamar a tu función de backend o SQLite si es necesario
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
                'Ingresa tu correo electrónico registrado y te enviaremos instrucciones para restablecer tu contraseña.',
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
                  onPressed: _sendRecoveryEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 104, 191, 99),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
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
