import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/emergency_service.dart';
import '../data/api_service.dart';

class EmergencyController extends GetxController {

  final EmergencyService _service = EmergencyService();
  final ApiService _api = ApiService();
  
  // 1. No asignamos el cliente directamente aquí para evitar el error de null en el arranque
SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      // Si aún no inicializa, lanzamos un error más descriptivo o manejamos el null
      throw Exception("Supabase no ha sido inicializado aún.");
    }
  }

  String telefonoEmergencia = '';
  
  var lastAlertDate = 'Cargando...'.obs;
  var alertStatus = 'Sin alertas activas'.obs;
  var historyList = [].obs;

  @override
  void onInit() {
    super.onInit();
    // Ejecutamos la carga inicial de forma segura
    initController();
  }

  Future<void> initController() async {
     solicitarPermisos();
     obtenerTelefono();
     fetchLastAlert(); // Movido aquí para asegurar orden
  }

  Future<void> solicitarPermisos() async {
    try {
      await [Permission.sms, Permission.phone].request();
    } catch (e) {
      print("❌ Error al solicitar permisos: $e");
    }
  }

  Future<void> obtenerTelefono() async {
    try {
      final paciente = await _api.getPacienteActual();
      // 2. Validación de nulidad más estricta
      if (paciente != null && paciente['telefono'] != null) {
        telefonoEmergencia = paciente['telefono'].toString();
      }
    } catch (e) {
      print("❌ Error obtener teléfono: $e");
    }
  }

  Future<void> fetchLastAlert() async {
    try {
      final paciente = await _api.getPacienteActual();
      if (paciente == null) {
        lastAlertDate.value = "Error: Sin perfil";
        return;
      }
      
      final idLogueado = paciente['id_paciente'];

      final response = await _supabase
          .from('emergencias')
          .select('fecha_evento')
          .eq('id_paciente', idLogueado) 
          .order('fecha_evento', ascending: false)
          .limit(1)
          .maybeSingle();

      // 3. Verificación de respuesta y del campo específico
      if (response != null && response['fecha_evento'] != null) {
        DateTime fecha = DateTime.parse(response['fecha_evento']);
        // Formateo manual para evitar fallos
        String dia = fecha.day.toString().padLeft(2, '0');
        String mes = fecha.month.toString().padLeft(2, '0');
        String hora = fecha.hour.toString().padLeft(2, '0');
        String minuto = fecha.minute.toString().padLeft(2, '0');
        
        lastAlertDate.value = "$dia/$mes/${fecha.year} · $hora:$minuto";
      } else {
        lastAlertDate.value = "Sin registros";
      }
    } catch (e) {
      print("❌ Error en fetchLastAlert: $e");
      lastAlertDate.value = "Error al cargar";
    }
  }

  Future<void> fetchHistory() async {
    try {
      final paciente = await _api.getPacienteActual();
      if (paciente == null) return;
      final idLogueado = paciente['id_paciente'];

      final List<dynamic> data = await _supabase
          .from('emergencias')
          .select()
          .eq('id_paciente', idLogueado) 
          .order('fecha_evento', ascending: false);
      
      historyList.assignAll(data);
    } catch (e) {
      print("❌ Error fetchHistory: $e");
      Get.snackbar("Error", "No se pudo cargar el historial");
    }
  }

  void confirmEmergency() {
    Get.defaultDialog(
      title: "Confirmar emergencia",
      middleText: "¿Enviar alerta de emergencia?",
      textConfirm: "Sí",
      textCancel: "Cancelar",
      buttonColor: const Color(0xFFEF5350),
      onConfirm: () {
        Get.back();
        iniciarCuentaRegresiva();
      },
    );
  }

  Future<void> iniciarCuentaRegresiva() async {
    alertStatus.value = "Iniciando...";
    Get.snackbar("Emergencia", "Llamando en 5 segundos...", 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white
    );
    await Future.delayed(const Duration(seconds: 5));
    await enviarAlerta();
  }

  Future<void> enviarAlerta() async {
    // 4. Verificación de seguridad antes de proceder
    if (telefonoEmergencia.isEmpty) {
      Get.snackbar("Error", "No hay número de emergencia configurado");
      alertStatus.value = "Sin teléfono destino";
      return;
    }

    try {
      final paciente = await _api.getPacienteActual();
      if (paciente == null) throw Exception("No se pudo obtener datos del paciente");

      final idPaciente = paciente['id_paciente'];
      final telefonoDoctor = paciente['telefono_doctor'];
      final mensaje = "🚨 Emergencia: paciente requiere ayuda inmediata";

      // Insertar en Supabase
      await _supabase.from('emergencias').insert({
        'id_paciente': idPaciente,
        'mensaje_medico': mensaje,
        'llamada_familiar': true,
        'fecha_evento': DateTime.now().toIso8601String(),
      });
      
      fetchLastAlert();

      print("📞 Iniciando llamada...");
      alertStatus.value = "Llamada en curso...";
      await _service.realizarLlamada(telefonoEmergencia);

      await Future.delayed(const Duration(seconds: 2));

      print("📩 Abriendo SMS para familiar...");
      alertStatus.value = "Abriendo SMS familiar...";
      await _service.enviarSMS(telefonoEmergencia);

      // 5. Manejo seguro del teléfono del doctor (si es null no crashea)
      if (telefonoDoctor != null && telefonoDoctor.toString().trim().isNotEmpty) {
        await Future.delayed(const Duration(seconds: 1)); 
        print("📩 Abriendo SMS para doctor...");
        alertStatus.value = "Abriendo SMS doctor...";
        await _service.enviarSMS(telefonoDoctor.toString());
      }

      alertStatus.value = "Protocolo completado";
      Get.snackbar("Éxito", "Protocolo de emergencia finalizado");
      
      Future.delayed(const Duration(seconds: 10), () => alertStatus.value = "Sin alertas activas");

    } catch (e) {
      print("❌ Error flujo emergencia: $e");
      alertStatus.value = "Error en protocolo";
      Get.snackbar("Error", "Ocurrió un fallo en el sistema de emergencia");
    }
  }
}