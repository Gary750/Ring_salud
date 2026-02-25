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

  // (Futuro) Obtener el historial de confirmaciones
  // Future<List<Map<String, dynamic>>> fetchHistory(int idPaciente) async { ... }
}
