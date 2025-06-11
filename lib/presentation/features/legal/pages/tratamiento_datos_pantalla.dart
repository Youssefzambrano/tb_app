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
                  'Evita TB se compromete a proteger la privacidad de sus usuarios. '
                  'Los datos personales y de salud recopilados se utilizan exclusivamente para el seguimiento del tratamiento '
                  'de la tuberculosis y fines educativos dentro de la aplicación. No se comparten con terceros sin autorización previa. '
                  'El almacenamiento de la información se realiza con medidas básicas de seguridad, y su uso está limitado al personal autorizado. '
                  'Al aceptar estas políticas, el usuario consiente el tratamiento temporal de sus datos según la Ley 1581 de 2012 de Colombia. '
                  'Esta es una versión provisional mientras se publica la política oficial. '
                  'En cualquier momento, el usuario puede solicitar la eliminación de sus datos a través de los medios de contacto dispuestos.',
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
