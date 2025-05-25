import 'package:flutter/material.dart';

class TratamientoDatosPantalla extends StatelessWidget {
  const TratamientoDatosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tratamiento de Datos'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Política de Tratamiento de Datos',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x26000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Phasellus imperdiet, nulla et dictum interdum, nisi lorem egestas odio, '
                  'vitae scelerisque enim ligula venenatis dolor. Maecenas nisl est, ultrices nec congue eget, '
                  'auctor vitae massa. Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Suspendisse euismod, nisi vel consectetur euismod, nisl nunc.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
