import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/session_controller.dart';
import 'chequeo_positivo_pantalla.dart';
import 'chequeo_negativo_pantalla.dart';

class ModuloAutochequeoPantalla extends StatefulWidget {
  const ModuloAutochequeoPantalla({super.key});

  @override
  State<ModuloAutochequeoPantalla> createState() =>
      _ModuloAutochequeoPantallaState();
}

class _ModuloAutochequeoPantallaState extends State<ModuloAutochequeoPantalla> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  bool _sinSintomas = false;
  bool _enviando = false;
  bool _cargando = true;

  List<Map<String, dynamic>> _sintomas = [];
  final Set<int> _selectedIds = {};
  int? _idTratamiento;
  int? _idPaciente;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _cargarDatos();
    if (mounted) _verificarSemana();
  }

  Future<void> _cargarDatos() async {
    final idUsuario = SessionController().idUsuario;
    if (idUsuario == null) return;

    _idPaciente = idUsuario;
    final supabase = Supabase.instance.client;

    final tratamiento = await supabase
        .from('tratamiento_paciente')
        .select('id')
        .eq('id_paciente', idUsuario)
        .eq('estado', 'En curso')
        .maybeSingle();

    _idTratamiento = tratamiento?['id'] as int?;

    final sintomasData = await supabase.from('sintoma').select('id, nombre');

    if (mounted) {
      setState(() {
        _sintomas = List<Map<String, dynamic>>.from(sintomasData);
        _cargando = false;
      });
    }
  }

  Future<void> _verificarSemana() async {
    if (_idTratamiento == null) return;

    final now = DateTime.now();
    final inicioSemana = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final inicioStr = '${inicioSemana.year}-${inicioSemana.month.toString().padLeft(2, '0')}-${inicioSemana.day.toString().padLeft(2, '0')}';

    // El seguimiento semanal se registra en seguimiento_paciente
    final existing = await Supabase.instance.client
        .from('seguimiento_paciente')
        .select('id')
        .eq('id_tratamiento_paciente', _idTratamiento!)
        .gte('fecha_reporte', inicioStr)
        .limit(1)
        .maybeSingle();

    if (existing != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Autochequeo ya realizado'),
          content: const Text(
            'Ya completaste tu autochequeo esta semana. Solo se permite uno por semana.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFF67BF63)),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _siguientePagina() {
    if (_sinSintomas) {
      _enviarChequeo();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _paginaActual++);
  }

  Future<void> _enviarChequeo() async {
    setState(() => _enviando = true);

    try {
      final bool haySintomas = !_sinSintomas && _selectedIds.isNotEmpty;
      final supabase = Supabase.instance.client;
      final now = DateTime.now();
      final fechaStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      if (_idTratamiento != null && _idPaciente != null) {
        // 1. Crear registro de seguimiento semanal
        final seguimiento = await supabase
            .from('seguimiento_paciente')
            .insert({
              'id_paciente': _idPaciente,
              'id_tratamiento_paciente': _idTratamiento,
              'fecha_reporte': fechaStr,
              'dosis_omitidas': 0,
            })
            .select('id')
            .single();

        final idSeguimiento = seguimiento['id'] as int;

        // 2. Insertar síntomas si hay alguno seleccionado
        if (haySintomas) {
          final rows = _selectedIds
              .map((id) => {
                    'id_seguimiento': idSeguimiento,
                    'id_sintoma': id,
                    'fecha_registro': fechaStr,
                  })
              .toList();
          await supabase.from('sintomas_paciente').insert(rows);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => haySintomas
              ? const ChequeoPositivoPantalla()
              : const ChequeoNegativoPantalla(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar autochequeo: $e')),
      );
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final bool enPagina1 = _paginaActual == 0;
    final bool botonEsEnviar = !enPagina1 || _sinSintomas;

    final mitad = (_sintomas.length / 2).ceil();
    final pagina1Sintomas = _sintomas.take(mitad).toList();
    final pagina2Sintomas = _sintomas.skip(mitad).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/evita_dudas.png',
                  width: 160,
                  height: 160,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Autochequeo semanal',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  enPagina1
                      ? '¿Presentas alguno de los siguientes síntomas?'
                      : 'Selecciona los que hayas presentado',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: _sinSintomas
                                ? const Color(0xFF67BF63).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _sinSintomas
                                  ? const Color(0xFF67BF63)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: const Text(
                              'No tengo síntomas',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF67BF63),
                              ),
                            ),
                            secondary: const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF67BF63),
                            ),
                            value: _sinSintomas,
                            activeColor: const Color(0xFF67BF63),
                            onChanged: (val) => setState(() {
                              _sinSintomas = val ?? false;
                              if (_sinSintomas) _selectedIds.clear();
                            }),
                          ),
                        ),
                        const Divider(height: 12),
                        ...pagina1Sintomas.map((s) {
                          final id = s['id'] as int;
                          return CheckboxListTile(
                            title: Text(
                              s['nombre'] as String,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: _sinSintomas
                                    ? Colors.grey.shade400
                                    : Colors.black87,
                              ),
                            ),
                            value: _selectedIds.contains(id),
                            activeColor: const Color(0xFF67BF63),
                            onChanged: _sinSintomas
                                ? null
                                : (val) => setState(() {
                                      if (val == true) {
                                        _selectedIds.add(id);
                                      } else {
                                        _selectedIds.remove(id);
                                      }
                                    }),
                          );
                        }),
                      ],
                    ),
                    ListView(
                      children: pagina2Sintomas.map((s) {
                        final id = s['id'] as int;
                        return CheckboxListTile(
                          title: Text(
                            s['nombre'] as String,
                            style: const TextStyle(fontFamily: 'Manrope'),
                          ),
                          value: _selectedIds.contains(id),
                          activeColor: const Color(0xFF67BF63),
                          onChanged: (val) => setState(() {
                            if (val == true) {
                              _selectedIds.add(id);
                            } else {
                              _selectedIds.remove(id);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enviando
                      ? null
                      : (botonEsEnviar ? _enviarChequeo : _siguientePagina),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          botonEsEnviar ? 'Enviar respuesta' : 'Siguiente',
                          style: const TextStyle(
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
    );
  }
}
