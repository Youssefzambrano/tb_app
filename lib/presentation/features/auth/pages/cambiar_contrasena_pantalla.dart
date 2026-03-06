import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/session_controller.dart';

class CambiarContrasenaPantalla extends StatefulWidget {
  const CambiarContrasenaPantalla({super.key});

  @override
  State<CambiarContrasenaPantalla> createState() =>
      _CambiarContrasenaPantallaState();
}

class _CambiarContrasenaPantallaState extends State<CambiarContrasenaPantalla> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _actualController = TextEditingController();
  final TextEditingController _nuevaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  bool _visibleActual = false;
  bool _visibleNueva = false;
  bool _visibleConfirmar = false;
  bool _cargando = false;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cambiarContrasena() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final email = SessionController().correoUsuario;
      final actual = _actualController.text;
      final nueva = _nuevaController.text;

      // 1. Verificar contraseña actual re-autenticando
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: actual,
      );

      // 2. Actualizar contraseña
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: nueva),
      );

      HapticFeedback.lightImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = e.message.contains('Invalid login')
          ? 'Contraseña actual incorrecta.'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        title: const Text('Cambiar contraseña'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo_app.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Actualiza tu contraseña',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _actualController,
                      label: 'Contraseña actual',
                      visible: _visibleActual,
                      toggle: () {
                        setState(() {
                          _visibleActual = !_visibleActual;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _nuevaController,
                      label: 'Nueva contraseña',
                      visible: _visibleNueva,
                      toggle: () {
                        setState(() {
                          _visibleNueva = !_visibleNueva;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        if (value == _actualController.text) {
                          return 'Debe ser diferente a la anterior';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmarController,
                      label: 'Confirmar contraseña',
                      visible: _visibleConfirmar,
                      toggle: () {
                        setState(() {
                          _visibleConfirmar = !_visibleConfirmar;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (value != _nuevaController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
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
                          'Cambiar contraseña',
                          style: TextStyle(fontFamily: 'Manrope', fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback toggle,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }
}
