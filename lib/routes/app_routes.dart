import 'package:flutter/material.dart';

// Splash
import '../presentation/splash/splash_screen.dart';

// Auth
import '../presentation/features/auth/pages/ingresar_pantalla.dart';
import '../presentation/features/auth/pages/confirmar_correo_pantalla.dart';
import '../presentation/features/auth/pages/formulario_registro_pantalla.dart';
import '../presentation/features/auth/pages/recuperar_contrasena_pantalla.dart';
import '../presentation/features/auth/pages/cambiar_contrasena_pantalla.dart';

// Bienvenida
import '../presentation/features/bienvenida/pages/bienvenida_pantalla.dart';

// Inicio
import '../presentation/features/inicio/pages/inicio_usuario_pantalla.dart';

// Perfil
import '../presentation/features/perfil/pages/completar_perfil_pantalla.dart';
import '../presentation/features/perfil/pages/perfil_completado_pantalla.dart';

// Autochequeo
import '../presentation/features/autochequeo/pages/modulo_autochequeo_pantalla.dart';

// Tratamiento
import 'package:tb_app/presentation/features/tratamiento/pages/exito_toma_pantalla.dart';

class AppRoutes {
  static const splash = '/';
  static const bienvenida = '/bienvenida';
  static const login = '/login';
  static const registro = '/registro';
  static const confirmarCorreo = '/confirmar-correo';
  static const recuperarContrasena = '/recuperar-contrasena';
  static const cambiarContrasena = '/cambiar-contrasena';
  static const inicio = '/inicio';
  static const completarPerfil = '/completar-perfil';
  static const perfilCompletado = '/perfil-completado';
  static const autochequeo = '/autochequeo';
  static const exitoToma = '/exito-toma';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    bienvenida: (context) => const BienvenidaPantalla(),
    login: (context) => const IngresarPantalla(),
    registro: (context) => const RegistroPantalla(),
    confirmarCorreo: (context) => const ConfirmarCorreoPantalla(nombre: ''),
    recuperarContrasena: (context) => const RecuperarContrasenaPantalla(),
    cambiarContrasena: (context) => const CambiarContrasenaPantalla(),
    inicio: (context) => const InicioUsuarioPantalla(),
    completarPerfil: (context) => const CompletarPerfilPantalla(nombre: ''),
    perfilCompletado: (context) => const PerfilCompletadoPantalla(),
    autochequeo: (context) => const ModuloAutochequeoPantalla(),
    exitoToma: (context) => const ExitoTomaPantalla(),
  };
}
