import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryController {
  final supabase = Supabase.instance.client;

  // Obtiene todo el historial de los pacientes de este médico en un rango de fechas
  Future<List<Map<String, dynamic>>> fetchGlobalHistory(int daysAgo) async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      // 1. Obtener ID del médico
      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final int doctorId = doctorData['id_medico'];

      // 2. Obtener IDs de sus pacientes
      final pacientesData = await supabase.from('paciente').select('id_paciente').eq('id_medico', doctorId);
      if (pacientesData.isEmpty) return [];
      
      final List<int> idsPacientes = pacientesData.map<int>((p) => p['id_paciente'] as int).toList();

      // 3. Fecha límite según el filtro (Hoy, 7 días, 30 días)
      // Si daysAgo es 0 (Hoy), buscamos desde la medianoche de hoy
      DateTime startDate;
      final now = DateTime.now();
      if (daysAgo == 0) {
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        startDate = now.subtract(Duration(days: daysAgo));
      }

      // 4. Súper Consulta: Recordatorios + Tratamientos + Info Paciente + Historial
      final response = await supabase
          .from('recordatorios_medicacion')
          .select('''
            id_recordatorio,
            fecha_hora_programada,
            enviado,
            confirmado,
            tratamientos!inner (
              nombre_medicamento,
              dosis,
              paciente!inner (
                nombre,
                usuario
              )
            ),
            historial_confirmaciones (
              estado
            )
          ''')
          .inFilter('tratamientos.id_paciente', idsPacientes) // Solo mis pacientes
          .gte('fecha_hora_programada', startDate.toIso8601String()) // Desde la fecha de filtro
          .lte('fecha_hora_programada', now.toIso8601String()) // Hasta la hora actual
          .order('fecha_hora_programada', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error al cargar historial global: $e");
      return [];
    }
  }
}