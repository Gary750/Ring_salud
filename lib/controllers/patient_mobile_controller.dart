import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:get/get.dart'; 
import '../views/shared/auth_gate.dart';

import '../main.dart';

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

class PatientController extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Patient? patient;
  bool isLoading = false;
  bool sinInternet = false;
  bool _cerrandoSesion = false;
  bool isDownloadingPdf = false; 


  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final diagnosisController = TextEditingController();
  final phoneController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final allergiesController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  List<TreatmentForm> treatments = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> openMedicalRecipe() async {
    if (isDownloadingPdf) return;

    try {
      isDownloadingPdf = true;
      notifyListeners();

      final hayInternet = await hayInternetReal();
      if (!hayInternet) {
        Get.snackbar("Sin conexión", "Necesitas internet para ver la receta",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 800));

      Get.toNamed('/medical-recipe'); 
      
    } catch (e) {
      print("Error al abrir receta: $e");
    } finally {
      isDownloadingPdf = false;
      notifyListeners();
    }
  }

  void addTreatment() {
    treatments.add(TreatmentForm());
    notifyListeners();
  }

  void removeTreatment(int index) {
    if (index >= 0 && index < treatments.length) {
      treatments[index].dispose();
      treatments.removeAt(index);
      notifyListeners();
    }
  }

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
    await prefs.setString('paciente_draft', jsonEncode(draftData));
  }

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

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paciente_draft');
  }

  Future<bool> hayInternetReal() async {
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  Future<void> _guardarEnCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_cache', jsonEncode(data));
  }

  Future<void> _cargarDesdeCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString('patient_cache');

    if (cache != null) {
      final data = jsonDecode(cache);
      patient = Patient.fromMap(data);
    }
  }

  Future<void> cargarPerfil() async => await loadPatientProfile();

  Future<void> loadPatientProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final hayInternet = await hayInternetReal();
      sinInternet = !hayInternet;

      if (!hayInternet) {
        await _cargarDesdeCache();
        return;
      }

      final user = supabase.auth.currentUser;
      final userEmail = user?.email;

      if (userEmail == null) {
        patient = null;
        return;
      }

      final data = await supabase
          .from('paciente')
          .select()
          .eq('correo', userEmail)
          .maybeSingle();

      if (data != null) {
        patient = Patient.fromMap(data);
        await _guardarEnCache(data);
      } else {
        patient = null;
      }

    } catch (e) {
      sinInternet = true;
      await _cargarDesdeCache();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPatient(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw "No hay sesión activa";

      final doctorData = await supabase
          .from('medico')
          .select('id_medico')
          .eq('correo', userEmail)
          .single();

      final int doctorId = doctorData['id_medico'];

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

      for (var t in treatments) {
        final int dias = int.tryParse(t.endDateController.text) ?? 7;
        final int frecuencia = int.tryParse(t.frequencyController.text) ?? 8;
        final inicio = DateTime.now();
        final fin = inicio.add(Duration(days: dias));

        final tratamiento = await supabase.from('tratamientos').insert({
          'id_paciente': newPatientId,
          'nombre_medicamento': t.nameController.text,
          'dosis': t.doseController.text,
          'frecuencia_horas': frecuencia,
          'fecha_inicio': inicio.toIso8601String(),
          'fecha_fin': fin.toIso8601String(),
        }).select('id_tratamiento').single();

        final int idTratamiento = tratamiento['id_tratamiento'];
        List<Map<String, dynamic>> recordatorios = [];
        DateTime actual = inicio;

        while (actual.isBefore(fin)) {
          recordatorios.add({
            'id_tratamiento': idTratamiento,
            'fecha_hora_programada': actual.toIso8601String(),
            'enviado': false,
            'confirmado': false,
            'horario_limite': actual.add(const Duration(hours: 1)).toIso8601String(),
          });
          actual = actual.add(Duration(hours: frecuencia));
        }

        if (recordatorios.isNotEmpty) {
          await supabase.from('recordatorios_medicacion').insert(recordatorios);
        }
      }

      await clearDraft();
      if (context.mounted) {
        _mostrarSnack(context, "Paciente registrado con éxito");
      }
      return true;

    } catch (e) {
      if (context.mounted) {
        _mostrarSnack(context, "Error: $e", esError: true);
      }
    }
    return false;
  }

  Future<void> logout(BuildContext context) async {
    if (_cerrandoSesion) return;
    _cerrandoSesion = true;
    notifyListeners();

    try {
      final hayInternet = await hayInternetReal();
      
      if (hayInternet) {
        await supabase.auth.signOut(scope: SignOutScope.global).timeout(
          const Duration(seconds: 2),
          onTimeout: () => supabase.auth.signOut(scope: SignOutScope.local),
        );
      } else {
        await supabase.auth.signOut(scope: SignOutScope.local);
      }
    } catch (e) {
      print("LOGOUT ERROR: $e");
      try { await supabase.auth.signOut(scope: SignOutScope.local); } catch (_) {}
    } finally {
      patient = null;
      for (var t in treatments) { t.dispose(); }
      treatments.clear();
      await clearDraft();

      _cerrandoSesion = false;
      notifyListeners();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    }
  }

  void _mostrarSnack(BuildContext context, String msg, {bool esError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? Colors.red : Colors.blue,
      ),
    );
  }

  @override
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

    for (var t in treatments) {
      t.dispose();
    }
    super.dispose();
  }
}