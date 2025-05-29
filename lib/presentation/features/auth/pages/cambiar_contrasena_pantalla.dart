import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final String _contrasenaAlmacenada = '123456';

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _cambiarContrasena() {
    if (_formKey.currentState!.validate()) {
      final nueva = _nuevaController.text;

      debugPrint('Contraseña cambiada exitosamente a: $nueva');
      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
                        if (value != _contrasenaAlmacenada) {
                          return 'Contraseña actual incorrecta';
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
                  onPressed: _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
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
