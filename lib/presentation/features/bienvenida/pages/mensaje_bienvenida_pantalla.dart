import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/pages/formulario_registro_pantalla.dart';

class MensajeBienvenidaPantalla extends StatefulWidget {
  const MensajeBienvenidaPantalla({super.key});

  @override
  State<MensajeBienvenidaPantalla> createState() =>
      _MensajeBienvenidaPantallaState();
}

class _MensajeBienvenidaPantallaState extends State<MensajeBienvenidaPantalla> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Bienvenido',
      'description':
          '¡Hola! Soy Evita, tu guía en este camino. Evita estar solo, Evita perder las ganas, Evita olvidar tus medicinas. Estoy aquí para ayudarte paso a paso con tu tratamiento contra la tuberculosis (también llamada TB). ¡Vamos juntos!',
      'image': 'assets/images/evita_feliz.png',
    },
    {
      'title': 'Te acompaño paso a paso',
      'description':
          'Cada día cuenta. Conmigo, Evita olvidar, Evita las dudas, Evita volver atrás. Yo te recordaré tus medicinas, te daré ánimo y responderé tus preguntas. ¡Tú puedes con la TB!!',
      'image': 'assets/images/evita_calendario.png',
    },
    {
      'title': '¡Vamos a vencer la tuberculosis!',
      'description':
          'Con tu fuerza y mi apoyo, Evita rendirte, Evita mirar atrás, Evita perder la esperanza. Hoy empiezas tu camino para vencer la tuberculosis (TB). ¡Cree en ti, yo estaré aquí para ayudarte!',
      'image': 'assets/images/evita_celebra.png',
    },
  ];

  void _onNextPressed() {
    HapticFeedback.lightImpact();
    if (_currentPage == _pages.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegistroPantalla()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Image.asset(
                          page['image']!,
                          height: 230,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 10,
                  width: _currentPage == index ? 22 : 10,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? const Color(0xFF67BF63)
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Comenzar'
                        : 'Continuar',
                    style: const TextStyle(fontSize: 18, fontFamily: 'Manrope'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
