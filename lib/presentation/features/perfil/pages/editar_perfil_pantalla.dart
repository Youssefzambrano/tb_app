import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/session_controller.dart';

class EditarPerfilPantalla extends StatefulWidget {
  const EditarPerfilPantalla({super.key});

  @override
  State<EditarPerfilPantalla> createState() => _EditarPerfilPantallaState();
}

class _EditarPerfilPantallaState extends State<EditarPerfilPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _telefonoContactoCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _contactoCtrl.dispose();
    _telefonoContactoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final id = SessionController().idUsuario;
    if (id == null) return;

    try {
      final supabase = Supabase.instance.client;

      final usuario = await supabase
          .from('usuario')
          .select('direccion, telefono')
          .eq('id', id)
          .single();

      final paciente = await supabase
          .from('paciente')
          .select('nombre_contacto_emergencia, telefono_contacto_emergencia')
          .eq('id', id)
          .single();

      _direccionCtrl.text = usuario['direccion'] ?? '';
      _telefonoCtrl.text = usuario['telefono'] ?? '';
      _contactoCtrl.text = paciente['nombre_contacto_emergencia'] ?? '';
      _telefonoContactoCtrl.text =
          paciente['telefono_contacto_emergencia'] ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final id = SessionController().idUsuario;
    if (id == null) return;

    setState(() => _guardando = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('usuario').update({
        'direccion': _direccionCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
      }).eq('id', id);

      await supabase.from('paciente').update({
        'nombre_contacto_emergencia': _contactoCtrl.text.trim(),
        'telefono_contacto_emergencia': _telefonoContactoCtrl.text.trim(),
      }).eq('id', id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de contacto',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _campo(
                        controller: _direccionCtrl,
                        label: 'Dirección',
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 16),
                      _campo(
                        controller: _telefonoCtrl,
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Contacto de emergencia',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _campo(
                        controller: _contactoCtrl,
                        label: 'Nombre del contacto',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _campo(
                        controller: _telefonoContactoCtrl,
                        label: 'Teléfono del contacto',
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF67BF63),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Guardar cambios',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF67BF63)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF67BF63), width: 2),
        ),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Campo requerido' : null,
    );
  }
}
