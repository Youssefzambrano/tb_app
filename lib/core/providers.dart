import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories_impl/dosis_repository_impl.dart';
import '../data/repositories_impl/tratamiento_repository_impl.dart';
import '../data/repositories_impl/medicacion_repository_impl.dart';
import '../domain/usecases/obtener_dashboard_paciente_usecase.dart';
import '../presentation/controllers/dashboard_peciente_controller.dart';
import '../presentation/controllers/resumen_fase_controller.dart';

final supabase = Supabase.instance.client;

final dosisRepo = DosisRepositoryImpl(supabase: supabase);
final tratamientoRepo = TratamientoRepositoryImpl(supabase: supabase);
final medicacionRepo = MedicacionRepositoryImpl(supabase: supabase);

final dashboardPacienteUseCase = ObtenerDashboardPacienteUseCase(
  tratamientoRepo: tratamientoRepo,
  dosisRepo: dosisRepo,
  medicacionRepo: medicacionRepo,
);

final dashboardPacienteController = DashboardPacienteController(
  useCase: dashboardPacienteUseCase,
);

final resumenFaseController = ResumenFaseController(
  useCase: dashboardPacienteUseCase,
);
