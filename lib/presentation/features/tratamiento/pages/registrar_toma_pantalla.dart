import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../controllers/registrar_toma_controller.dart';
import '../../../controllers/dashboard_peciente_controller.dart';

class RegistrarTomaPantalla extends StatefulWidget {
  const RegistrarTomaPantalla({super.key});

  @override
  State<RegistrarTomaPantalla> createState() => _RegistrarTomaPantallaState();
}

class _RegistrarTomaPantallaState extends State<RegistrarTomaPantalla> {
  File? _fotoFile;
  bool _fotoConfirmada = false;

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (foto != null && mounted) {
      setState(() {
        _fotoFile = File(foto.path);
        _fotoConfirmada = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardPacienteController>(context);
    final resumen = controller.resumen;

    final now = DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final fase = resumen?.faseActual ?? '...';
    final medicamento = resumen?.medicamentoActual ?? '...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Toma'),
        backgroundColor: const Color(0xFF67BF63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset('assets/images/evita_feliz.png', width: 130, height: 130),
              const SizedBox(height: 12),
              const Text(
                'Estás a punto de registrar una nueva toma',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Manrope', fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildTomaInfo(fase, medicamento, fechaStr),
              const SizedBox(height: 24),
              _buildFotoSection(),
              const SizedBox(height: 24),
              _buildRegistrarButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTomaInfo(String fase, String medicamento, String fecha) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC3D9), Color(0xFF67BF63)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Color(0x4B1A1F24), offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _infoItem('Fase', fase),
          const SizedBox(height: 12),
          _infoItem('Medicamento', medicamento),
          const SizedBox(height: 12),
          _infoItem('Fecha', fecha),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    if (_fotoFile != null && !_fotoConfirmada) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _fotoFile!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _tomarFoto,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Repetir', style: TextStyle(fontFamily: 'Manrope')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF67BF63),
                    side: const BorderSide(color: Color(0xFF67BF63)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _fotoConfirmada = true),
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Usar esta foto',
                    style: TextStyle(fontFamily: 'Manrope'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67BF63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_fotoFile != null && _fotoConfirmada) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _fotoFile!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF67BF63), size: 20),
              const SizedBox(width: 6),
              const Text(
                'Foto confirmada',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFF67BF63),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _tomarFoto,
                child: const Text(
                  'Cambiar',
                  style: TextStyle(fontFamily: 'Manrope'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _tomarFoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text(
          'Tomar fotografía del medicamento',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF67BF63),
          side: const BorderSide(color: Color(0xFF67BF63), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRegistrarButton(BuildContext context) {
    final habilitado = _fotoConfirmada;
    return Column(
      children: [
        if (!_fotoConfirmada)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Debes tomar y confirmar la fotografía para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  habilitado ? const Color(0xFF67BF63) : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: habilitado
                ? () async {
                    await RegistrarTomaController().registrarTomaDesdeSesion(
                      context: context,
                      fotoFile: _fotoFile,
                    );
                  }
                : null,
            child: const Text(
              'Registrar Toma',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
