import 'package:flutter/material.dart';

class TerminosCondicionesPantalla extends StatelessWidget {
  const TerminosCondicionesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        backgroundColor: const Color.fromARGB(255, 104, 191, 99),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Términos y Condiciones de Uso',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Evita TB recopila algunos datos personales y de salud para ayudarte a seguir tu tratamiento '
                'de forma segura y personalizada. Esta información solo se usa dentro de la app y no se comparte '
                'con terceros. Al usar esta aplicación, aceptas temporalmente que tus datos sean tratados con fines '
                'médicos y educativos. Esta es una versión provisional del aviso de privacidad, mientras se actualizan '
                'nuestras políticas conforme a la Ley 1581 de 2012 de Colombia. Tus datos se almacenan con medidas '
                'básicas de seguridad. Si no estás de acuerdo, por favor no continúes con el uso de la aplicación.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
