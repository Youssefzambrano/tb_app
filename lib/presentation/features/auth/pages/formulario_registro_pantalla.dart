import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../data/datasources/remote/supabase/auth_supabase_service.dart';
import 'confirmar_correo_pantalla.dart';
import '../../legal/pages/tratamiento_datos_pantalla.dart';

class RegistroPantalla extends StatefulWidget {
  const RegistroPantalla({super.key});

  @override
  State<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends State<RegistroPantalla> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();
  final _authService = AuthSupabaseService();
  final _secureStorage = const FlutterSecureStorage();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _aceptaPolitica = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _registrarse() async {
    if (_formKey.currentState!.validate() && _aceptaPolitica) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final nombre = _nombreController.text.trim();

      try {
        await _authService.signUpWithEmail(email: email, password: password);

        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmarCorreoPantalla(nombre: nombre),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo_app.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(
                      controller: _nombreController,
                      label: 'Nombre completo',
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      controller: _emailController,
                      label: 'Correo electrónico',
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      controller: _passwordController,
                      label: 'Contraseña',
                      obscure: !_passwordVisible,
                      iconToggle: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                      visible: _passwordVisible,
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      controller: _confirmarController,
                      label: 'Confirmar contraseña',
                      obscure: !_confirmPasswordVisible,
                      iconToggle: () {
                        setState(
                          () =>
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                        );
                      },
                      visible: _confirmPasswordVisible,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'No coincide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _aceptaPolitica,
                          onChanged: (value) {
                            setState(() {
                              _aceptaPolitica = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF67BF63),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Acepto la ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'política de tratamiento de datos',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF67BF63),
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const TratamientoDatosPantalla(),
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF67BF63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _aceptaPolitica ? _registrarse : null,
                        child: const Text(
                          'Registrarme',
                          style: TextStyle(fontSize: 18, fontFamily: 'Manrope'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    bool visible = false,
    VoidCallback? iconToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon:
            iconToggle != null
                ? IconButton(
                  icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: iconToggle,
                )
                : null,
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Campo requerido';
            if (label.contains('Contraseña') && value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
    );
  }
}
