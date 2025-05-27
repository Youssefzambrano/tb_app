import 'package:flutter/material.dart';
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

  final Map<String, bool> _sintomas = {
    'Piel y ojos amarillos': false,
    'Dolor abdominal fuerte': false,
    'Le pica o rasca el cuerpo': false,
    'Tiene la piel roja o con brote': false,
    'Se indigesta con comida': false,
    'Hormigueo en dedos o manos': false,
    'Visión borrosa': false,
    'Escucha menos': false,
    'Orina poco': false,
  };

  void _siguientePagina() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _paginaActual++);
  }

  void _enviarChequeo() {
    final bool haySintomas = _sintomas.values.contains(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                haySintomas
                    ? const ChequeoPositivoPantalla()
                    : const ChequeoNegativoPantalla(),
      ),
    );
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
                  'assets/images/evita_dudas.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Autochequeo semanal',
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
                      ? '¿Presentas alguno de los siguientes síntomas?'
                      : 'Selecciona los que hayas presentado',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Column(
                      children:
                          _sintomas.keys
                              .take(5)
                              .map(
                                (sintoma) => CheckboxListTile(
                                  title: Text(sintoma),
                                  value: _sintomas[sintoma],
                                  onChanged:
                                      (val) => setState(
                                        () => _sintomas[sintoma] = val ?? false,
                                      ),
                                ),
                              )
                              .toList(),
                    ),
                    Column(
                      children:
                          _sintomas.keys
                              .skip(5)
                              .map(
                                (sintoma) => CheckboxListTile(
                                  title: Text(sintoma),
                                  value: _sintomas[sintoma],
                                  onChanged:
                                      (val) => setState(
                                        () => _sintomas[sintoma] = val ?? false,
                                      ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _paginaActual == 0 ? _siguientePagina : _enviarChequeo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _paginaActual == 0 ? 'Siguiente' : 'Enviar respuesta',
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
