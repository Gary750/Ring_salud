import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDetailController {
  final supabase = Supabase.instance.client;

  // Obtener los tratamientos de un paciente específico
  Future<List<Map<String, dynamic>>> fetchTreatments(int idPaciente) async {
    try {
      final response = await supabase
          .from('tratamientos')
          .select()
          .eq('id_paciente', idPaciente);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  //Obtener el historial de confirmaciones
  Future<List<Map<String, dynamic>>> fetchHistory(int idPaciente) async {
    try {
      // Hacemos un JOIN entre recordatorios, tratamientos e historial
      final response = await supabase
          .from('recordatorios_medicacion')
          .select('''
            id_recordatorio,
            fecha_hora_programada,
            confirmado,
            tratamientos!inner (
              id_paciente,
              nombre_medicamento,
              dosis
            ),
            historial_confirmaciones (
              fecha_confirmacion,
              estado
            )
          ''')
          .eq('tratamientos.id_paciente', idPaciente) // Filtramos por el paciente actual
          .lte('fecha_hora_programada', DateTime.now().toIso8601String()) // Solo tomas que ya pasaron o tocan hoy
          .order('fecha_hora_programada', ascending: false) // Las más recientes arriba
          .limit(20); // Mostramos los últimos 20 registros

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}