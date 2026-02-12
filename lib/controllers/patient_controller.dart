import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Clase Tratammientos
class TreatmentForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController frequencyController =TextEditingController(); 
  final TextEditingController endDateController = TextEditingController();

  void dispose() {
    nameController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    endDateController.dispose();
  }
}

class PatientController {
  // --- Datos Clínicos ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();

  // --- Datos de Acceso y Credenciales ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //! Lista de dinamica de tratamientos
  List<TreatmentForm> treatments = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // Métodos para la vista
  void addTreatment() {
    treatments.add(TreatmentForm());
  }

  void removeTreatment(int index) {
    treatments[index].dispose();
    treatments.removeAt(index);
  }

  Future<bool> createPatient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;


    if (treatments.isEmpty) {
      _mostrarSnack(context, "Agregue al menos un medicamento", esError: true);
      return false;
    } 

    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw "No hay sesión activa";

      // 1. Obtener ID Médico
      final doctorData = await supabase
          .from('medico')
          .select('id_medico')
          .eq('correo', userEmail)
          .single();
      final int doctorId = doctorData['id_medico'];

      // 2. Auth (Login del Paciente)
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'rol': 'paciente'},
      );

      if (res.user != null) {
        // 3. Insertar Paciente y RECUPERAR el ID generado (select())
        final patientData = await supabase
            .from('paciente')
            .insert({
              'id_medico': doctorId,
              'nombre': nameController.text.trim(),
              'edad': int.tryParse(ageController.text) ?? 0,
              'telefono': phoneController.text.trim(),
              'correo': emailController.text.trim(),
              'enfermedad': diagnosisController.text.trim(),
              'alergias': allergiesController.text.trim(),
              'usuario': usernameController.text.trim(),
              'contrasena': passwordController.text.trim(),
              'numero_emergencia': emergencyPhoneController.text.trim(),
            })
            .select('id_paciente')
            .single(); // <--- Importante: .select().single()

        final int newPatientId = patientData['id_paciente'];

        // 4. Insertar Tratamientos en la tabla 'tratamientos'
        if (treatments.isNotEmpty) {
          for (var t in treatments) {
            await supabase.from('tratamientos').insert({
              'id_paciente': newPatientId, // FK vinculando al paciente
              'nombre_medicamento': t.nameController.text.trim(),
              'dosis': t.doseController.text.trim(),
              // Convertimos texto a entero para la BD (int4)
              'frecuencia_horas': int.tryParse(t.frequencyController.text) ?? 8,
              'fecha_inicio': DateTime.now()
                  .toIso8601String(), // Fecha actual por defecto
              'fecha_fin': DateTime.now().add(Duration(days: int.tryParse(t.endDateController.text) ?? 7)).toIso8601String(),
            });
          }
        }

        _mostrarSnack(
          context,
          "Paciente y tratamientos registrados",
          esError: false,
        );
        return true;
      }
    } catch (e) {
      _mostrarSnack(context, "Error: $e", esError: true);
    }
    return false;
  }

  void _mostrarSnack(BuildContext context, String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? Colors.red : Colors.blue,
      ),
    );
  }

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    diagnosisController.dispose();
    phoneController.dispose();
    emergencyPhoneController.dispose();
    emailController.dispose();
    allergiesController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    // Limpiar controladores de tratamientos
    for (var t in treatments) {
      t.dispose();
    } 
  }
}
