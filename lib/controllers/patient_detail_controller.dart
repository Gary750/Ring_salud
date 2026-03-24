import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDetailController {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTreatments(int idPaciente) async {
    try {
      final response = await supabase
          .from('tratamientos')
          .select()
          .eq('id_paciente', idPaciente);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error al obtener tratamientos: $e"); // ✅ Log real
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory(int idPaciente) async {
    try {
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
          .eq('tratamientos.id_paciente', idPaciente)
          .lte('fecha_hora_programada', DateTime.now().toIso8601String())
          .order('fecha_hora_programada', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error al obtener historial: $e"); // ✅ Log real
      return [];
    }
  }

  Future<bool> deactivateAllTreatments(int idPaciente) async {
    try {
      final dateNow = DateTime.now().toIso8601String();

      final trats = await supabase
          .from('tratamientos')
          .select('id_tratamiento')
          .eq('id_paciente', idPaciente)
          .gt('fecha_fin', dateNow);

      if (trats.isEmpty) return true;

      // ✅ Batch: de 2N queries a 2 queries fijas
      final ids = List<int>.from(trats.map((t) => t['id_tratamiento']));

      await supabase
          .from('recordatorios_medicacion')
          .delete()
          .inFilter('id_tratamiento', ids)
          .gt('fecha_hora_programada', dateNow);

      await supabase
          .from('tratamientos')
          .update({'fecha_fin': dateNow})
          .inFilter('id_tratamiento', ids);

      return true;
    } catch (e) {
      debugPrint("Error al desactivar tratamientos: $e"); // ✅ Log real
      return false;
    }
  }

  Future<bool> addSingleTreatment(
    int idPaciente,
    String nombre,
    String dosis,
    int frec,
    int dias,
  ) async {
    // ✅ Validación: frec > 0 evita loop infinito
    if (frec <= 0) {
      debugPrint("Error: frecuencia debe ser mayor a 0");
      return false;
    }

    try {
      final fechaInicio = DateTime.now();
      final fechaFin    = fechaInicio.add(Duration(days: dias));

      final res = await supabase.from('tratamientos').insert({
        'id_paciente':      idPaciente,
        'nombre_medicamento': nombre,
        'dosis':            dosis,
        'frecuencia_horas': frec,
        'fecha_inicio':     fechaInicio.toIso8601String(),
        'fecha_fin':        fechaFin.toIso8601String(),
      }).select('id_tratamiento').single();

      final int idT = res['id_tratamiento'];

      // ✅ Límite de recordatorios para evitar inserciones masivas
      const int maxRecordatorios = 500;
      List<Map<String, dynamic>> recordatorios = [];
      DateTime horaActual = fechaInicio;

      while (horaActual.isBefore(fechaFin) && recordatorios.length < maxRecordatorios) {
        recordatorios.add({
          'id_tratamiento':      idT,
          'fecha_hora_programada': horaActual.toIso8601String(),
          'enviado':             false,
          'confirmado':          false,
          'horario_limite':      horaActual.add(const Duration(hours: 1)).toIso8601String(),
        });
        horaActual = horaActual.add(Duration(hours: frec));
      }

      if (recordatorios.isNotEmpty) {
        await supabase.from('recordatorios_medicacion').insert(recordatorios);
      }
      return true;
    } catch (e) {
      debugPrint("Error al agregar tratamiento: $e"); // ✅ Log real
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEmergencies(int idPaciente) async {
    try {
      final response = await supabase
          .from('emergencias')
          .select()
          .eq('id_paciente', idPaciente)
          .order('fecha_evento', ascending: false); // Las más recientes primero
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error al obtener emergencias: $e");
      return [];
    }
  }

  
}