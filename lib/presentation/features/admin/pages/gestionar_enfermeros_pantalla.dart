import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionarEnfermerosPantalla extends StatefulWidget {
  const GestionarEnfermerosPantalla({super.key});

  @override
  State<GestionarEnfermerosPantalla> createState() =>
      _GestionarEnfermerosPantallaState();
}

class _GestionarEnfermerosPantallaState
    extends State<GestionarEnfermerosPantalla> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _enfermeros = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await _supabase
          .from('usuario')
          .select('id, nombre, correo_electronico, numero_documento, activo')
          .eq('nivel_acceso', 'Enfermero')
          .order('nombre');
      setState(() => _enfermeros = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      setState(() => _error = 'Error al cargar enfermeros: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _toggleActivo(Map<String, dynamic> enfermero) async {
    final nuevoEstado = !(enfermero['activo'] as bool? ?? true);
    try {
      await _supabase
          .from('usuario')
          .update({'activo': nuevoEstado})
          .eq('id', enfermero['id'] as int);
      await _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarDialogoCrear() {
    _mostrarDialogo();
  }

  void _mostrarDialogoEditar(Map<String, dynamic> enfermero) {
    _mostrarDialogo(enfermero: enfermero);
  }

  void _mostrarDialogo({Map<String, dynamic>? enfermero}) {
    final esEdicion = enfermero != null;
    final nombreCtrl =
        TextEditingController(text: esEdicion ? enfermero['nombre'] as String? : '');
    final correoCtrl = TextEditingController(
        text: esEdicion ? enfermero['correo_electronico'] as String? : '');
    final docCtrl = TextEditingController(
        text: esEdicion ? enfermero['numero_documento'] as String? : '');
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool guardando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(
            esEdicion ? 'Editar Enfermero' : 'Nuevo Enfermero',
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _campo(nombreCtrl, 'Nombre completo', required: true),
                  const SizedBox(height: 12),
                  _campo(correoCtrl, 'Correo electrónico',
                      tipo: TextInputType.emailAddress,
                      required: true,
                      readOnly: esEdicion),
                  const SizedBox(height: 12),
                  _campo(docCtrl, 'Número de documento'),
                  if (!esEdicion) ...[
                    const SizedBox(height: 12),
                    _campo(passCtrl, 'Contraseña temporal',
                        required: true, obscure: true),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: guardando
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setStateDialog(() => guardando = true);
                      try {
                        if (esEdicion) {
                          await _supabase.from('usuario').update({
                            'nombre': nombreCtrl.text.trim(),
                            'numero_documento': docCtrl.text.trim().isEmpty
                                ? null
                                : docCtrl.text.trim(),
                          }).eq('id', enfermero['id'] as int);
                        } else {
                          await _supabase.functions.invoke(
                            'admin-create-user',
                            body: {
                              'nombre': nombreCtrl.text.trim(),
                              'correo': correoCtrl.text.trim().toLowerCase(),
                              'password': passCtrl.text,
                              'nivelAcceso': 'Enfermero',
                              'numeroDocumento': docCtrl.text.trim().isEmpty
                                  ? null
                                  : docCtrl.text.trim(),
                            },
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _cargar();
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                        setStateDialog(() => guardando = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF67BF63),
                foregroundColor: Colors.white,
              ),
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(esEdicion ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _campo(
    TextEditingController ctrl,
    String label, {
    TextInputType tipo = TextInputType.text,
    bool required = false,
    bool obscure = false,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      obscureText: obscure,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Enfermeros'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrear,
        backgroundColor: const Color(0xFF67BF63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _enfermeros.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay enfermeros registrados.',
                        style: TextStyle(fontFamily: 'Manrope'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _enfermeros.length,
                        itemBuilder: (_, i) => _buildTarjeta(_enfermeros[i]),
                      ),
                    ),
    );
  }

  Widget _buildTarjeta(Map<String, dynamic> e) {
    final activo = e['activo'] as bool? ?? true;
    final nombre = (e['nombre'] as String?) ?? 'Sin nombre';
    final correo = (e['correo_electronico'] as String?) ?? '';
    final doc = (e['numero_documento'] as String?) ?? '';
    final initials = nombre.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: activo
              ? const Color(0xFF67BF63)
              : Colors.grey.shade300,
          child: Text(
            initials,
            style: TextStyle(
              color: activo ? Colors.white : Colors.grey.shade600,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(correo, style: const TextStyle(fontFamily: 'Manrope', fontSize: 13)),
            if (doc.isNotEmpty)
              Text(
                'Cédula: $doc',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activo
                    ? const Color(0xFF67BF63).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: activo ? const Color(0xFF67BF63) : Colors.grey.shade500,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'editar') _mostrarDialogoEditar(e);
                if (v == 'toggle') _toggleActivo(e);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(activo ? 'Desactivar' : 'Activar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
