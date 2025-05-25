import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../perfil/pages/completar_perfil_pantalla.dart';

class ConfirmarCorreoPantalla extends StatefulWidget {
  const ConfirmarCorreoPantalla({super.key});

  @override
  State<ConfirmarCorreoPantalla> createState() =>
      _ConfirmarCorreoPantallaState();
}

class _ConfirmarCorreoPantallaState extends State<ConfirmarCorreoPantalla> {
  final TextEditingController _codigoController = TextEditingController();
  bool _codigoValido = false;

  void _verificarCodigo() {
    if (_codigoController.text.length == 6) {
      setState(() => _codigoValido = true);
    } else {
      setState(() => _codigoValido = false);
    }
  }

  void _reenviarCodigo() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código reenviado al correo electrónico'),
          backgroundColor: Color(0xFF67BF63),
        ),
      );
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

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
                'Te enviamos un código a tu correo electrónico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (_) => _verificarCodigo(),
                decoration: InputDecoration(
                  labelText: 'Código de verificación',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _codigoValido
                          ? () {
                            debugPrint('Código confirmado');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const CompletarPerfilPantalla(),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reenviarCodigo,
                child: const Text(
                  'Reenviar código',
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
