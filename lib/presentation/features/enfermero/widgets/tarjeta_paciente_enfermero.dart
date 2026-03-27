import 'package:flutter/material.dart';
import '../../../../domain/entities/enfermero_resumen_paciente.dart';

class TarjetaPacienteEnfermero extends StatelessWidget {
  final EnfermeroResumenPaciente paciente;
  final VoidCallback onTap;

  const TarjetaPacienteEnfermero({
    super.key,
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final alertaColor =
        paciente.tieneAlerta ? const Color(0xFFE74C3C) : const Color(0xFF67BF63);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paciente.nombrePaciente,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: alertaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      paciente.tieneAlerta ? 'Alerta' : 'Estable',
                      style: TextStyle(
                        color: alertaColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                paciente.correoPaciente,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Fase: ${paciente.faseActual}'),
                  _chip(
                    'Dosis: ${paciente.dosisTomadas}/${paciente.dosisTotales}',
                  ),
                  _chip(
                    paciente.dosisHoyTomada ? 'Dosis hoy: Si' : 'Dosis hoy: No',
                    backgroundColor:
                        paciente.dosisHoyTomada ? Colors.green[50] : Colors.orange[50],
                  ),
                  _chip(
                    paciente.reportoSintomasHoy
                        ? 'Sintomas reportados'
                        : 'Sin sintomas',
                    backgroundColor:
                        paciente.reportoSintomasHoy ? Colors.red[50] : Colors.green[50],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, {Color? backgroundColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF0F3F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
