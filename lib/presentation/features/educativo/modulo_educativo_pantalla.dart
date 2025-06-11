import 'package:flutter/material.dart';
import '../../../services/modulo_educativo_service.dart';
import 'modal_educativo.dart';

class ModuloEducativoPantalla extends StatefulWidget {
  const ModuloEducativoPantalla({super.key});

  @override
  State<ModuloEducativoPantalla> createState() =>
      _ModuloEducativoPantallaState();
}

class _ModuloEducativoPantallaState extends State<ModuloEducativoPantalla> {
  late Future<Map<String, dynamic>> _futuroBloques;
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  final List<String> nombresBloques = [
    'que_debes_saber',
    'habitos_saludables',
    'recomendaciones_tratamiento',
    'evitar_contagio',
  ];

  @override
  void initState() {
    super.initState();
    _futuroBloques = cargarModuloEducativo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _nombreBloqueBonito(String key) {
    switch (key) {
      case 'que_debes_saber':
        return 'Qué debes saber';
      case 'habitos_saludables':
        return 'Hábitos saludables';
      case 'recomendaciones_tratamiento':
        return 'Recomendaciones';
      case 'evitar_contagio':
        return 'evitar contagios';
      default:
        return key;
    }
  }

  String _imagenPorBloque(String key) {
    switch (key) {
      case 'que_debes_saber':
        return 'assets/images_modulo_educativo/Qué debes saber sobre  tuberculosis (TB).png';
      case 'habitos_saludables':
        return 'assets/images_modulo_educativo/Qué habitos saludables debo realizar.png';
      case 'recomendaciones_tratamiento':
        return 'assets/images_modulo_educativo/Qué recomendaciones debo seguir durante el tratamiento.png';
      case 'evitar_contagio':
        return 'assets/images_modulo_educativo/Como evitar contagiar a otros.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: const Color(0xFF67BF63),
        title: const Text('Módulo Educativo'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futuroBloques,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final bloques = snapshot.data!;

            return Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Aprende sobre tu tratamiento',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: nombresBloques.length,
                    onPageChanged: (i) => setState(() => _paginaActual = i),
                    itemBuilder: (context, i) {
                      final bloqueKey = nombresBloques[i];
                      final titulo = _nombreBloqueBonito(bloqueKey);
                      final imagen = _imagenPorBloque(bloqueKey);
                      final bloque = bloques[bloqueKey] as List;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 16,
                        ),
                        child: Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFF67BF63),
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  imagen,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.height * 0.30,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 34),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  titulo,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: SizedBox(
                                  width: 220, // Ancho fijo, puedes ajustar
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF67BF63),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Manrope',
                                      ),
                                      elevation: 6,
                                    ),
                                    child: const Text('Ver información'),
                                    onPressed:
                                        () => mostrarModalBloqueEducativo(
                                          context,
                                          bloque,
                                          titulo,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _IndicadorCarrusel(
                  total: nombresBloques.length,
                  actual: _paginaActual,
                ),
                const SizedBox(height: 18),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget para los puntos del carrusel
class _IndicadorCarrusel extends StatelessWidget {
  final int total;
  final int actual;

  const _IndicadorCarrusel({required this.total, required this.actual});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: actual == i ? 32 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: actual == i ? const Color(0xFF67BF63) : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
