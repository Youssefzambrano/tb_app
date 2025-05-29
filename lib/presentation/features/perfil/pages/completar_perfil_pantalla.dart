import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'perfil_completado_pantalla.dart';
import '../../../../domain/usecases/registrar_usuario_usecase.dart';
import '../../../../data/repositories_impl/usuario_repository_impl.dart';
import '../../../../data/datasources/remote/supabase/auth_supabase_service.dart';
import '../../../../domain/usecases/registrar_paciente_usecase.dart';
import '../../../../data/repositories_impl/paciente_repository_impl.dart';

class CompletarPerfilPantalla extends StatefulWidget {
  final String nombre;
  const CompletarPerfilPantalla({super.key, required this.nombre});

  @override
  State<CompletarPerfilPantalla> createState() =>
      _CompletarPerfilPantallaState();
}

class _CompletarPerfilPantallaState extends State<CompletarPerfilPantalla> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _contactoEmergenciaController =
      TextEditingController();
  final TextEditingController _telefonoEmergenciaController =
      TextEditingController();

  String? _tipoDocumento;
  String? _genero;
  DateTime? _fechaNacimiento;
  int _paginaActual = 0;

  final PageController _pageController = PageController();

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  void _siguientePagina() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _paginaActual++);
    }
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      final registrarUsuarioUseCase = RegistrarUsuarioUseCase(
        UsuarioRepositoryImpl(
          supabase: Supabase.instance.client,
          authService: AuthSupabaseService(),
        ),
      );

      final registrarPacienteUseCase = RegistrarPacienteUseCase(
        PacienteRepositoryImpl(supabase: Supabase.instance.client),
      );

      try {
        final usuario = await registrarUsuarioUseCase(
          nombre: widget.nombre,
          fechaNacimiento: _fechaNacimiento!,
          genero: _genero!,
          tipoDocumento: _tipoDocumento!,
          numeroDocumento: _documentoController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );

        await registrarPacienteUseCase(
          idUsuario: usuario.id,
          nombreContacto: _contactoEmergenciaController.text.trim(),
          telefonoContacto: _telefonoEmergenciaController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PerfilCompletadoPantalla(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar perfil: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _contactoEmergenciaController.dispose();
    _telefonoEmergenciaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_app.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Completa tu perfil',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _paginaActual == 0
                      ? 'Datos personales'
                      : 'Información de contacto',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _tipoDocumento,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de documento',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Cedula de Ciudadania',
                                child: Text('Cedula de Ciudadania'),
                              ),
                              DropdownMenuItem(
                                value: 'Pasaporte',
                                child: Text('Pasaporte'),
                              ),
                              DropdownMenuItem(
                                value: 'Cedula de Extranjeria',
                                child: Text('Cedula de Extranjeria'),
                              ),
                              DropdownMenuItem(
                                value: 'NUIP',
                                child: Text('NUIP'),
                              ),
                            ],
                            onChanged:
                                (value) =>
                                    setState(() => _tipoDocumento = value),
                            validator:
                                (value) =>
                                    value == null ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _documentoController,
                            decoration: const InputDecoration(
                              labelText: 'Número de documento',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _selectFechaNacimiento(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de nacimiento',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _fechaNacimiento == null
                                    ? 'Selecciona una fecha'
                                    : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_fechaNacimiento!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _genero,
                            decoration: const InputDecoration(
                              labelText: 'Género',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Masculino',
                                child: Text('Masculino'),
                              ),
                              DropdownMenuItem(
                                value: 'Femenino',
                                child: Text('Femenino'),
                              ),
                              DropdownMenuItem(
                                value: 'Otro',
                                child: Text('Otro'),
                              ),
                            ],
                            onChanged:
                                (value) => setState(() => _genero = value),
                            validator:
                                (value) =>
                                    value == null ? 'Campo requerido' : null,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TextFormField(
                            controller: _direccionController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contactoEmergenciaController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre contacto de emergencia',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefonoEmergenciaController,
                            decoration: const InputDecoration(
                              labelText: 'Número contacto de emergencia',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _paginaActual == 0 ? _siguientePagina : _guardarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _paginaActual == 0 ? 'Siguiente' : 'Guardar perfil',
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 18),
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
