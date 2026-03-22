import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertsController {
  final supabase = Supabase.instance.client;

  // Obtiene los datos necesarios para generar las alertas
  Future<Map<String, dynamic>> fetchAlertsData(int daysAgo) async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return {'records': [], 'totalPacientes': 0};

      // 1. ID del Médico
      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final int doctorId = doctorData['id_medico'];

      // 2. IDs de los Pacientes y Total
      final pacientesData = await supabase.from('paciente').select('id_paciente').eq('id_medico', doctorId);
      final int totalPacientes = pacientesData.length;
      if (totalPacientes == 0) return {'records': [], 'totalPacientes': 0};
      
      final List<int> idsPacientes = pacientesData.map<int>((p) => p['id_paciente'] as int).toList();

      // 3. Fecha de inicio según el filtro
      DateTime startDate;
      final now = DateTime.now();
      if (daysAgo == 0) {
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        startDate = now.subtract(Duration(days: daysAgo));
      }

      // 4. Buscar tomas desde la fecha de inicio hasta HOY (Solo pasado)
      final response = await supabase
          .from('recordatorios_medicacion')
          .select('''
            id_recordatorio,
            fecha_hora_programada,
            confirmado,
            enviado,
            tratamientos!inner (
              nombre_medicamento,
              paciente!inner (
                id_paciente,
                nombre,
                usuario
              )
            ),
            historial_confirmaciones (
              estado,
              fecha_confirmacion
            )
          ''')
          .inFilter('tratamientos.id_paciente', idsPacientes)
          .gte('fecha_hora_programada', startDate.toIso8601String())
          .lte('fecha_hora_programada', now.toIso8601String()) // Solo eventos pasados
          .order('fecha_hora_programada', ascending: false);

      return {
        'records': List<Map<String, dynamic>>.from(response),
        'totalPacientes': totalPacientes
      };
    } catch (e) {
      debugPrint("Error al cargar alertas: $e");
      return {'records': [], 'totalPacientes': 0};
    }
  }
}