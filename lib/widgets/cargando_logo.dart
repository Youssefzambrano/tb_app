import 'package:flutter/material.dart';

class CargandoLogo extends StatelessWidget {
  const CargandoLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo_app.png', width: 120),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Color(0xFF67BF63)),
        ],
      ),
    );
  }
}
