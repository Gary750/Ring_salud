import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';
import 'notification_service.dart'; 

class RecordatoriosService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> obtenerRecordatoriosYProgramarAlarmas() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Sesión no iniciada");

      // 1. Obtener ID del Paciente
      final pacienteData = await supabase
          .from('paciente')
          .select('id_paciente')
          .eq('correo', user.email!)
          .single();

      final idPaciente = pacienteData['id_paciente'];

      // 2. Definir rango de HOY
      final ahora = DateTime.now();
      final inicioDia = DateTime(ahora.year, ahora.month, ahora.day).toIso8601String();
      final finDia = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59).toIso8601String();

      // 3. Consultar Base de Datos
      final response = await supabase
          .from('recordatorios_medicacion')
          .select('''
            id_recordatorio,
            fecha_hora_programada,
            confirmado,
            tratamientos!inner(
              nombre_medicamento,
              dosis
            )
          ''')
          .eq('tratamientos.id_paciente', idPaciente)
          .gte('fecha_hora_programada', inicioDia)
          .lte('fecha_hora_programada', finDia)
          .order('fecha_hora_programada');

      final lista = List<Map<String, dynamic>>.from(response);

      // 4. --- LÓGICA DE ALARMAS AUTOMÁTICA ---
      for (var item in lista) {
        final bool yaConfirmado = item['confirmado'] == true;
        final DateTime horaProgramada = DateTime.parse(item['fecha_hora_programada']);
        
        if (!yaConfirmado && horaProgramada.isAfter(ahora)) {
          await NotificationService.programarAlarma(
            item['id_recordatorio'], 
            item['tratamientos']['nombre_medicamento'], 
            horaProgramada
          );
          log("Alarma programada para: ${item['tratamientos']['nombre_medicamento']} a las ${item['fecha_hora_programada']}");
        }
      }

      return lista;

    } catch (e) {
      log("Error en RecordatoriosService: $e");
      rethrow;
    }
  }

  Future<void> confirmarToma(int idRecordatorio) async {
    try {
      await supabase
          .from('recordatorios_medicacion')
          .update({'confirmado': true})
          .eq('id_recordatorio', idRecordatorio);

      
      log("Toma $idRecordatorio confirmada en DB.");
    } catch (e) {
      log("Error al confirmar: $e");
      rethrow;
    }
  }
}