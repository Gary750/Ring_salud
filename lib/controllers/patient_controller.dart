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

        // 4. Insertar Tratamientos y Generar Recordatorios
        if (treatments.isNotEmpty) {
          for (var t in treatments) {
            final int diasDuracion = int.tryParse(t.endDateController.text) ?? 7;
            final int frecuenciaHoras = int.tryParse(t.frequencyController.text) ?? 8;
            
            // Definir fechas del tratamiento
            final DateTime fechaInicio = DateTime.now(); // Inicia en este momento
            final DateTime fechaFin = fechaInicio.add(Duration(days: diasDuracion));

            // A. Insertamos el tratamiento y PEDIMOS EL ID DE VUELTA (.select)
            final tratamientoData = await supabase.from('tratamientos').insert({
              'id_paciente': newPatientId,
              'nombre_medicamento': t.nameController.text.trim(),
              'dosis': t.doseController.text.trim(),
              'frecuencia_horas': frecuenciaHoras,
              'fecha_inicio': fechaInicio.toIso8601String(),
              'fecha_fin': fechaFin.toIso8601String(),
            }).select('id_tratamiento').single();

            final int nuevoTratamientoId = tratamientoData['id_tratamiento'];

            // B.Generar la lista de recordatorios
            List<Map<String, dynamic>> listaRecordatorios = [];
            DateTime horaTomaActual = fechaInicio;

            // Bucle: Mientras la hora de la toma sea menor a la fecha de fin
            while (horaTomaActual.isBefore(fechaFin)) {
              listaRecordatorios.add({
                'id_tratamiento': nuevoTratamientoId, // Vinculamos al tratamiento
                'fecha_hora_programada': horaTomaActual.toIso8601String(),
                'enviado': false,
                'confirmado': false,
                // Límite para tomarla: Le damos 1 hora de tolerancia
                'horario_limite': horaTomaActual.add(const Duration(hours: 1)).toIso8601String(), 
              });

              // Sumamos las horas de la frecuencia para la siguiente toma (Ej: +8 horas)
              horaTomaActual = horaTomaActual.add(Duration(hours: frecuenciaHoras));
            }

            // C. Insertar todos los recordatorios de golpe en la BD (Bulk Insert)
            if (listaRecordatorios.isNotEmpty) {
              await supabase.from('recordatorios_medicacion').insert(listaRecordatorios);
            }
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
