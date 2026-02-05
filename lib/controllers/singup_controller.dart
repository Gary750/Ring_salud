import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController {
  // --- CONTROLADORES DE TEXTO ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController(); // Nuevo
  final TextEditingController phoneController = TextEditingController();    // Nuevo
  final TextEditingController emailController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController(); // Nuevo
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassowrdController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  
  // Por defecto registramos como doctor si no hay selector
  String selectedRole = 'doctor'; 

  Future<bool> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    if (passwordController.text != confirmPassowrdController.text) {
      _mostrarMensaje(context, "Las contraseñas no coinciden", esError: true);
      return false;
    }

    try {
      // 1. Crear Auth en Supabase (Login)
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'rol': selectedRole}, 
      );

      if (res.user != null) {
        // 2. Insertar en tu tabla 'medico'
        // Mapeamos TUS inputs a TUS columnas de BD
        await supabase.from('medico').insert({
          'nombre': nameController.text.trim(),
          'usuario': usernameController.text.trim(), // Ahora usamos el input de usuario
          'telefono': phoneController.text.trim(),   // Input de teléfono
          'correo': emailController.text.trim(),
          'disponibilidad_json': availabilityController.text.trim(), // Input de disponibilidad
          'contrasena': passwordController.text.trim(),
        });

        _mostrarMensaje(context, "Médico registrado exitosamente", esError: false);
        return true; 
      }
    } on PostgrestException catch (e) {
      _mostrarMensaje(context, "Error BD: ${e.message}", esError: true);
    } on AuthException catch (e) {
      _mostrarMensaje(context, "Error Auth: ${e.message}", esError: true);
    } catch (e) {
      _mostrarMensaje(context, "Error: $e", esError: true);
    }
    return false;
  }

  void _mostrarMensaje(BuildContext context, String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: esError ? Colors.redAccent : Colors.green),
    );
  }

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    availabilityController.dispose();
    passwordController.dispose();
    confirmPassowrdController.dispose();
  }
}