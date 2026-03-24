import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreatmentForm {
  final TextEditingController nameController      = TextEditingController();
  final TextEditingController doseController      = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  final TextEditingController endDateController   = TextEditingController();

  void dispose() {
    nameController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    endDateController.dispose();
  }
}

class PatientController {
  final TextEditingController nameController           = TextEditingController();
  final TextEditingController ageController            = TextEditingController();
  final TextEditingController diagnosisController      = TextEditingController();
  final TextEditingController phoneController          = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController allergiesController      = TextEditingController();
  final TextEditingController emailController          = TextEditingController();
  final TextEditingController usernameController       = TextEditingController();
  final TextEditingController passwordController       = TextEditingController();

  List<TreatmentForm> treatments = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  void addTreatment() => treatments.add(TreatmentForm());

  void removeTreatment(int index) {
    treatments[index].dispose();
    treatments.removeAt(index);
  }

  // ==========================================
  // BORRADOR
  // ==========================================

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftData = {
      'nombre':    nameController.text,
      'edad':      ageController.text,
      'enfermedad':diagnosisController.text,
      'telefono':  phoneController.text,
      'correo':    emailController.text,
      'emergencia':emergencyPhoneController.text,
      'alergias':  allergiesController.text,
      'usuario':   usernameController.text,
      // ✅ Contraseña excluida del borrador — localStorage es inseguro
    };
    await prefs.setString('paciente_draft', jsonEncode(draftData));
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString('paciente_draft');
    if (draftString != null) {
      final draftData = jsonDecode(draftString);
      nameController.text           = draftData['nombre']     ?? '';
      ageController.text            = draftData['edad']       ?? '';
      diagnosisController.text      = draftData['enfermedad'] ?? '';
      phoneController.text          = draftData['telefono']   ?? '';
      emailController.text          = draftData['correo']     ?? '';
      emergencyPhoneController.text = draftData['emergencia'] ?? '';
      allergiesController.text      = draftData['alergias']   ?? '';
      usernameController.text       = draftData['usuario']    ?? '';
      // ✅ Contraseña no se carga del borrador
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paciente_draft');
  }

  // ==========================================
  // BASE DE DATOS
  // ==========================================

  Future<bool> createPatient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw Exception("No hay sesión activa");

      final doctorData = await supabase
          .from('medico')
          .select('id_medico')
          .eq('correo', userEmail)
          .single();
      final int doctorId = doctorData['id_medico'];

      // ✅ Edad validada antes de insertar
      final int edad = int.tryParse(ageController.text.trim()) ?? 0;
      if (edad <= 0) {
        if (context.mounted) _mostrarSnack(context, "La edad no es válida.", esError: true);
        return false;
      }

      final patientData = await supabase.from('paciente').insert({
        'id_medico':        doctorId,
        'nombre':           nameController.text.trim(),
        'edad':             edad,
        'telefono':         phoneController.text.trim(),
        'correo':           emailController.text.trim(),
        'enfermedad':       diagnosisController.text.trim(),
        'alergias':         allergiesController.text.trim(),
        'usuario':          usernameController.text.trim(),
        // ⚠️ Pendiente: hashear contraseña antes de guardar (bcrypt o Supabase Auth)
        'contrasena':       passwordController.text.trim(),
        'numero_emergencia':emergencyPhoneController.text.trim(),
      }).select('id_paciente').single();

      final int newPatientId = patientData['id_paciente'];

      for (var t in treatments) {
        final int dias  = int.tryParse(t.endDateController.text)   ?? 7;
        final int frec  = int.tryParse(t.frequencyController.text) ?? 8;

        // ✅ Guard: frec > 0 para evitar loop infinito
        if (frec <= 0) {
          debugPrint("Frecuencia inválida en tratamiento, se omite.");
          continue;
        }

        final DateTime fechaInicio = DateTime.now();
        final DateTime fechaFin    = fechaInicio.add(Duration(days: dias));

        final tratamientoData = await supabase.from('tratamientos').insert({
          'id_paciente':      newPatientId,
          'nombre_medicamento': t.nameController.text.trim(),
          'dosis':            t.doseController.text.trim(),
          'frecuencia_horas': frec,
          'fecha_inicio':     fechaInicio.toIso8601String(),
          'fecha_fin':        fechaFin.toIso8601String(),
        }).select('id_tratamiento').single();

        final int nuevoTratamientoId = tratamientoData['id_tratamiento'];

        // ✅ Límite de recordatorios para evitar inserciones masivas
        const int maxRecordatorios = 500;
        List<Map<String, dynamic>> listaRecordatorios = [];
        DateTime horaActual = fechaInicio;

        while (horaActual.isBefore(fechaFin) && listaRecordatorios.length < maxRecordatorios) {
          listaRecordatorios.add({
            'id_tratamiento':       nuevoTratamientoId,
            'fecha_hora_programada':horaActual.toIso8601String(),
            'enviado':              false,
            'confirmado':           false,
            'horario_limite':       horaActual.add(const Duration(hours: 1)).toIso8601String(),
          });
          horaActual = horaActual.add(Duration(hours: frec));
        }

        if (listaRecordatorios.isNotEmpty) {
          await supabase.from('recordatorios_medicacion').insert(listaRecordatorios);
        }
      }

      await clearDraft();

      // ✅ mounted verificado antes de usar context tras todos los awaits
      if (context.mounted) {
        _mostrarSnack(context, "Paciente y tratamientos registrados con éxito.", esError: false);
      }
      return true;

    } catch (e) {
      debugPrint("Error al crear paciente: $e"); // ✅ Log real
      if (context.mounted) {
        _mostrarSnack(context, "Ocurrió un error al registrar el paciente. Intenta de nuevo.", esError: true);
      }
      return false;
    }
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
    for (var t in treatments) t.dispose();
  }
}