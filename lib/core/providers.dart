import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories_impl/dosis_repository_impl.dart';
import '../data/repositories_impl/enfermero_dashboard_repository_impl.dart';
import '../domain/usecases/obtener_catalogo_sintomas_usecase.dart';
import '../data/repositories_impl/tratamiento_repository_impl.dart';
import '../data/repositories_impl/medicacion_repository_impl.dart';
import '../domain/usecases/obtener_dashboard_enfermero_usecase.dart';
import '../domain/usecases/obtener_dashboard_paciente_usecase.dart';
import '../domain/usecases/registrar_seguimiento_clinico_usecase.dart';
import '../domain/usecases/validar_toma_paciente_enfermero_usecase.dart';
import '../presentation/controllers/dashboard_peciente_controller.dart';
import '../presentation/controllers/enfermero_dashboard_controller.dart';
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

final enfermeroDashboardRepository = EnfermeroDashboardRepositoryImpl(
  supabase: supabase,
);

final obtenerDashboardEnfermeroUseCase = ObtenerDashboardEnfermeroUseCase(
  enfermeroDashboardRepository,
);

final validarTomaPacienteEnfermeroUseCase =
    ValidarTomaPacienteEnfermeroUseCase(enfermeroDashboardRepository);

final registrarSeguimientoClinicoUseCase = RegistrarSeguimientoClinicoUseCase(
  enfermeroDashboardRepository,
);

final obtenerCatalogoSintomasUseCase = ObtenerCatalogoSintomasUseCase(
  enfermeroDashboardRepository,
);

final enfermeroDashboardController = EnfermeroDashboardController(
  useCase: obtenerDashboardEnfermeroUseCase,
  validarTomaUseCase: validarTomaPacienteEnfermeroUseCase,
  registrarSeguimientoUseCase: registrarSeguimientoClinicoUseCase,
  obtenerCatalogoSintomasUseCase: obtenerCatalogoSintomasUseCase,
);
