import 'package:flutter/material.dart';
import 'package:ring_salud/views/mobile/home_mobile.dart';
import 'package:ring_salud/views/web/dashboard_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthController {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: userController.text.trim(),
        password: passwordController.text, // ✅ Sin .trim()
      );

      final User? user = res.user;

      if (user != null) {
        final String? rol = user.userMetadata?['rol'];

        // ✅ Verificar mounted antes de usar context tras await
        if (!context.mounted) return;

        if (kIsWeb) {
          if (rol == 'doctor' || rol == 'enfermero') {
            debugPrint('Login exitoso como Doctor o Enfermero'); // ✅
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardWeb()),
            );
          } else {
            await supabase.auth.signOut();
            if (!context.mounted) return;
            _mostrarError(context, "Acceso denegado: Los pacientes deben usar la App Móvil.");
          }
        } else {
          if (rol == 'paciente') {
            debugPrint("Bienvenido Paciente"); // ✅
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeMobile()),
            );
          } else {
            await supabase.auth.signOut();
            if (!context.mounted) return;
            _mostrarError(context, "Acceso denegado: Los doctores deben usar la versión web.");
          }
        }
      }
    } on AuthException catch (e) {
      _mostrarError(context, e.message);
    } catch (e) {
      debugPrint("Error inesperado: $e"); // ✅ Log real
      if (!context.mounted) return;
      _mostrarError(context, "Ocurrió un error inesperado. Intenta de nuevo."); // ✅ Mensaje genérico
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error de Autenticación"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void dispose() {
    userController.dispose();
    passwordController.dispose();
  }
}