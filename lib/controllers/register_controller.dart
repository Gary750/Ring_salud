import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController {
  // --- 1. Controladores de Texto ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // --- 2. Llave del Formulario ---
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // --- 3. Variable de Estado para el Rol (Por defecto 'paciente') ---
  String selectedRole = 'paciente'; 

  // --- 4. Cliente Supabase ---
  final supabase = Supabase.instance.client;

  // --- 5. Método de Registro ---
  Future<bool> register(BuildContext context) async {
    // A. Validar que los campos no estén vacíos
    if (!formKey.currentState!.validate()) return false;

    try {
      // B. Enviar datos a Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          // ¡Aquí es donde guardamos lo que el usuario eligió en la lista!
          'rol': selectedRole, 
        },
      );

      // C. Verificar éxito
      if (res.user != null) {
        _mostrarMensaje(context, "Cuenta de $selectedRole creada exitosamente", esError: false);
        return true; // Retornamos true para cerrar la pantalla
      }
    } on AuthException catch (e) {
      _mostrarMensaje(context, e.message, esError: true);
    } catch (e) {
      _mostrarMensaje(context, "Error inesperado: $e", esError: true);
    }
    return false;
  }

  // --- Helpers UI ---
  void _mostrarMensaje(BuildContext context, String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Limpieza de memoria ---
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}