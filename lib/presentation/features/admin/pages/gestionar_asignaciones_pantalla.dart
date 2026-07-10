import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionarAsignacionesPantalla extends StatefulWidget {
  const GestionarAsignacionesPantalla({super.key});

  @override
  State<GestionarAsignacionesPantalla> createState() =>
      _GestionarAsignacionesPantallaState();
}

class _GestionarAsignacionesPantallaState
    extends State<GestionarAsignacionesPantalla> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _asignaciones = [];
  List<Map<String, dynamic>> _enfermeros = [];
  List<Map<String, dynamic>> _pacientes = [];
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
      final asigs = await _supabase
          .from('paciente_enfermero')
          .select('id, id_paciente, id_enfermero');

      final enfs = await _supabase
          .from('usuario')
          .select('id, nombre')
          .eq('nivel_acceso', 'Enfermero')
          .order('nombre');

      final pacs = await _supabase
          .from('usuario')
          .select('id, nombre')
          .neq('nivel_acceso', 'Enfermero')
          .neq('nivel_acceso', 'administrador')
          .order('nombre');

      final enfermerosMap = {
        for (final e in enfs as List) (e['id'] as int): e['nombre'] as String,
      };
      final pacientesMap = {
        for (final p in pacs as List) (p['id'] as int): p['nombre'] as String,
      };

      final lista = (asigs as List).map((a) {
        final idPac = a['id_paciente'] as int;
        final idEnf = a['id_enfermero'] as int;
        return {
          'id': a['id'] as int,
          'id_paciente': idPac,
          'id_enfermero': idEnf,
          'nombre_paciente': pacientesMap[idPac] ?? 'Paciente #$idPac',
          'nombre_enfermero': enfermerosMap[idEnf] ?? 'Enfermero #$idEnf',
        };
      }).toList();

      setState(() {
        _asignaciones = lista;
        _enfermeros = List<Map<String, dynamic>>.from(enfs);
        _pacientes = List<Map<String, dynamic>>.from(pacs);
      });
    } catch (e) {
      setState(() => _error = 'Error al cargar asignaciones: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarAsignacion(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar asignación'),
        content: const Text('¿Deseas eliminar esta asignación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _supabase.from('paciente_enfermero').delete().eq('id', id);
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
    int? idPacienteSeleccionado;
    int? idEnfermeroSeleccionado;
    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text(
            'Nueva Asignación',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Paciente',
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: idPacienteSeleccionado,
                  items: _pacientes.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'] as int,
                      child: Text(
                        (p['nombre'] as String?) ?? '',
                        style: const TextStyle(fontFamily: 'Manrope'),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setStateDialog(() => idPacienteSeleccionado = v),
                  validator: (v) => v == null ? 'Selecciona un paciente' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Enfermero',
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: idEnfermeroSeleccionado,
                  items: _enfermeros.map((e) {
                    return DropdownMenuItem<int>(
                      value: e['id'] as int,
                      child: Text(
                        (e['nombre'] as String?) ?? '',
                        style: const TextStyle(fontFamily: 'Manrope'),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setStateDialog(() => idEnfermeroSeleccionado = v),
                  validator: (v) => v == null ? 'Selecciona un enfermero' : null,
                ),
              ],
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
                        await _supabase.from('paciente_enfermero').insert({
                          'id_paciente': idPacienteSeleccionado,
                          'id_enfermero': idEnfermeroSeleccionado,
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _cargar();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                        setStateDialog(() => guardando = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B7ED4),
                foregroundColor: Colors.white,
              ),
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Asignaciones'),
        backgroundColor: const Color(0xFF9B7ED4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrear,
        backgroundColor: const Color(0xFF9B7ED4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _asignaciones.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay asignaciones registradas.',
                        style: TextStyle(fontFamily: 'Manrope'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _asignaciones.length,
                        itemBuilder: (_, i) => _buildTarjeta(_asignaciones[i]),
                      ),
                    ),
    );
  }

  Widget _buildTarjeta(Map<String, dynamic> asig) {
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
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF9B7ED4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.link, color: Color(0xFF9B7ED4)),
        ),
        title: Text(
          asig['nombre_paciente'] as String,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              asig['nombre_enfermero'] as String,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _eliminarAsignacion(asig['id'] as int),
        ),
      ),
    );
  }
}
