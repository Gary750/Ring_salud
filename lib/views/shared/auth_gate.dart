import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import '../web/dashboard_web.dart'; 
import '../web/login_view_web.dart';
import '../mobile/home_mobile.dart'; 
import '../mobile/login_view_mobile.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. Pantalla de carga mientras revisa la sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // 2. ENRUTAMIENTO INTELIGENTE DEPENDIENDO DEL DISPOSITIVO
        if (session != null) {
          // --- USUARIO LOGUEADO ---
          if (kIsWeb) {
            return const DashboardWeb(); // Si es web, va al Panel Médico
          } else {
            return const HomeMobile();   // Si es celular, va a la App del Paciente
          }
        } else {
          // --- USUARIO SIN SESIÓN (Necesita Login) ---
          if (kIsWeb) {
            return const LoginViewWeb();    // Formulario de login para médicos
          } else {
            return const LoginViewMobile(); // Formulario de login para pacientes
          }
        }
      },
    );
  }
}