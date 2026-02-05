import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientController {
  // --- Datos Clínicos ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController(); 
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();

  // --- Datos de Acceso y Credenciales ---
  final TextEditingController emailController = TextEditingController(); // AHORA ES VITAL PARA EL LOGIN
  final TextEditingController controlNumberController = TextEditingController(); // Será el "nombre de usuario"
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  Future<bool> createPatient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    try {
      // 1. Obtener ID del Médico que está registrando
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw "No hay sesión activa";

      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final int doctorId = doctorData['id_medico'];

      // 2. CREAR EL AUTH (LOGIN) CON EL CORREO REAL
      // Antes usábamos el número de control, ahora usamos el emailController
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(), // <--- CAMBIO AQUÍ: Correo real
        password: passwordController.text.trim(),
        data: {'rol': 'paciente'}, // Metadato para saber que no es doctor
      );

      if (res.user != null) {
        // 3. GUARDAR EN LA BASE DE DATOS
        await supabase.from('paciente').insert({
          'id_medico': doctorId,
          'nombre': nameController.text.trim(),
          'edad': int.tryParse(ageController.text) ?? 0,
          'telefono': phoneController.text.trim(),
          'correo': emailController.text.trim(), 
          'enfermedad': diagnosisController.text.trim(),
          'alergias': allergiesController.text.trim(),
          'usuario': controlNumberController.text.trim(), 
          'contrasena': passwordController.text.trim(),
          'numero_emergencia': emergencyPhoneController.text.trim(),
        });

        _mostrarSnack(context, "Paciente registrado con éxito. Acceso: ${emailController.text}", esError: false);
        return true;
      }
    } on AuthException catch (e) {
      _mostrarSnack(context, "Error Auth: ${e.message}", esError: true);
    } on PostgrestException catch (e) {
      _mostrarSnack(context, "Error BD: ${e.message}", esError: true);
    } catch (e) {
      _mostrarSnack(context, "Error: $e", esError: true);
    }
    return false;
  }
  
  void _mostrarSnack(BuildContext context, String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: esError ? Colors.red : Colors.blue));
  }

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    diagnosisController.dispose();
    phoneController.dispose();
    emergencyPhoneController.dispose();
    emailController.dispose();
    allergiesController.dispose();
    controlNumberController.dispose();
    passwordController.dispose();
  }
}