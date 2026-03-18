import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CLASE AUXILIAR DE TRATAMIENTOS ---
class TreatmentForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController(); 
  final TextEditingController endDateController = TextEditingController();

  void dispose() {
    nameController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    endDateController.dispose();
  }
}

// --- CONTROLADOR PRINCIPAL ---
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

  //! Lista dinámica de tratamientos
  List<TreatmentForm> treatments = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // ==========================================
  // FUNCIONES PARA LA VISTA
  // ==========================================
  void addTreatment() {
    treatments.add(TreatmentForm());
  }

  void removeTreatment(int index) {
    treatments[index].dispose();
    treatments.removeAt(index);
  }

  // ==========================================
  // FUNCIONES PARA EL BORRADOR (SHARED_PREFS)
  // ==========================================
  
  // 1. Guarda los datos actuales en el navegador
  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftData = {
      'nombre': nameController.text,
      'edad': ageController.text,
      'enfermedad': diagnosisController.text,
      'telefono': phoneController.text,
      'correo': emailController.text,
      'emergencia': emergencyPhoneController.text,
      'alergias': allergiesController.text,
      'usuario': usernameController.text,
      'contrasena': passwordController.text,
    };
    // Convertir el mapa a un string JSON y guardarlo
    await prefs.setString('paciente_draft', jsonEncode(draftData));
  }

  // 2. Carga los datos guardados
  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString('paciente_draft');
    
    if (draftString != null) {
      final draftData = jsonDecode(draftString);
      nameController.text = draftData['nombre'] ?? '';
      ageController.text = draftData['edad'] ?? '';
      diagnosisController.text = draftData['enfermedad'] ?? '';
      phoneController.text = draftData['telefono'] ?? '';
      emailController.text = draftData['correo'] ?? '';
      emergencyPhoneController.text = draftData['emergencia'] ?? '';
      allergiesController.text = draftData['alergias'] ?? '';
      usernameController.text = draftData['usuario'] ?? '';
      passwordController.text = draftData['contrasena'] ?? '';
    }
  }

  // 3. Elimina el borrador (cuando ya se guardó en BD o se cancela)
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paciente_draft');
  }

  // ==========================================
  // LÓGICA DE BASE DE DATOS
  // ==========================================
  Future<bool> createPatient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw "No hay sesión activa";

      // 1. Obtener ID Médico actual
      final doctorData = await supabase
          .from('medico')
          .select('id_medico')
          .eq('correo', userEmail)
          .single();
      final int doctorId = doctorData['id_medico'];

      // 2. Insertar Paciente directamente en tu tabla
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
          .single();

      final int newPatientId = patientData['id_paciente'];

      // 3. Insertar Tratamientos y Generar Recordatorios
      if (treatments.isNotEmpty) {
        for (var t in treatments) {
          final int diasDuracion = int.tryParse(t.endDateController.text) ?? 7;
          final int frecuenciaHoras = int.tryParse(t.frequencyController.text) ?? 8;
          
          final DateTime fechaInicio = DateTime.now();
          final DateTime fechaFin = fechaInicio.add(Duration(days: diasDuracion));

          // A. Insertar tratamiento
          final tratamientoData = await supabase.from('tratamientos').insert({
            'id_paciente': newPatientId,
            'nombre_medicamento': t.nameController.text.trim(),
            'dosis': t.doseController.text.trim(),
            'frecuencia_horas': frecuenciaHoras,
            'fecha_inicio': fechaInicio.toIso8601String(),
            'fecha_fin': fechaFin.toIso8601String(),
          }).select('id_tratamiento').single();

          final int nuevoTratamientoId = tratamientoData['id_tratamiento'];

          // B. Generar recordatorios
          List<Map<String, dynamic>> listaRecordatorios = [];
          DateTime horaTomaActual = fechaInicio;

          while (horaTomaActual.isBefore(fechaFin)) {
            listaRecordatorios.add({
              'id_tratamiento': nuevoTratamientoId,
              'fecha_hora_programada': horaTomaActual.toIso8601String(),
              'enviado': false,
              'confirmado': false,
              'horario_limite': horaTomaActual.add(const Duration(hours: 1)).toIso8601String(), 
            });
            horaTomaActual = horaTomaActual.add(Duration(hours: frecuenciaHoras));
          }

          // C. Insertar masivo
          if (listaRecordatorios.isNotEmpty) {
            await supabase.from('recordatorios_medicacion').insert(listaRecordatorios);
          }
        }
      }

      // --- IMPORTANTE: LIMPIAR BORRADOR ---
      // Como el paciente se guardó exitosamente, borramos el borrador local
      await clearDraft();

      _mostrarSnack(context, "Paciente y tratamientos registrados con éxito", esError: false);
      return true;
      
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