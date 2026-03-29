import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication_model.dart';

class MedicationController {

  final supabase = Supabase.instance.client;

  Future<List<MedicationTask>> getTodayMedications() async {

    final response = await supabase
        .from('recordatorios_medicacion')
        .select()
        .order('fecha_hora_programada');

    return (response as List)
        .map((item) => MedicationTask.fromMap(item))
        .toList();
  }

  Future<void> confirmarToma(int idRecordatorio) async {

    final now = DateTime.now();

    await supabase
        .from('recordatorios_medicacion')
        .update({'confirmado': true})
        .eq('id_recordatorio', idRecordatorio);

    await supabase
        .from('historial_confirmacion')
        .insert({
          'id_recordatorio': idRecordatorio,
          'fecha_confirmacion': now.toIso8601String(),
          'estado': 'confirmado'
        });

    await supabase
        .from('notificaciones_medico')
        .insert({
          'mensaje': 'El paciente confirmó la toma de medicamento',
          'fecha': now.toIso8601String()
        });
  }
}