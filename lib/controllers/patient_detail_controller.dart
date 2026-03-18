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
Future<bool> deactivateAllTreatments(int idPaciente) async {
    try {
      final dateNow = DateTime.now().toIso8601String();
      
      // A. Buscar los tratamientos activos de este paciente
      final trats = await supabase.from('tratamientos')
          .select('id_tratamiento')
          .eq('id_paciente', idPaciente)
          .gt('fecha_fin', dateNow);

      if (trats.isEmpty) return true; // No hay nada que desactivar

      // B. Cancelar cada uno
      for (var t in trats) {
        int idT = t['id_tratamiento'];
        
        // Borrar recordatorios futuros (para que no le sigan llegando alertas)
        await supabase.from('recordatorios_medicacion')
            .delete()
            .eq('id_tratamiento', idT)
            .gt('fecha_hora_programada', dateNow);
            
        // Cambiar la fecha de fin a HOY
        await supabase.from('tratamientos')
            .update({'fecha_fin': dateNow})
            .eq('id_tratamiento', idT);
      }
      return true;
    } catch (e) {
      //debugPrint("Error al desactivar: $e");
      return false;
    }
  }

  // 4. AGREGAR NUEVO MEDICAMENTO (EDITAR PAUTA)
  Future<bool> addSingleTreatment(int idPaciente, String nombre, String dosis, int frec, int dias) async {
    try {
      final fechaInicio = DateTime.now();
      final fechaFin = fechaInicio.add(Duration(days: dias));

      // A. Insertar tratamiento
      final res = await supabase.from('tratamientos').insert({
        'id_paciente': idPaciente,
        'nombre_medicamento': nombre,
        'dosis': dosis,
        'frecuencia_horas': frec,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
      }).select('id_tratamiento').single();

      final int idT = res['id_tratamiento'];

      // B. Generar recordatorios automáticos
      List<Map<String, dynamic>> recordatorios = [];
      DateTime horaActual = fechaInicio;

      while (horaActual.isBefore(fechaFin)) {
        recordatorios.add({
          'id_tratamiento': idT,
          'fecha_hora_programada': horaActual.toIso8601String(),
          'enviado': false,
          'confirmado': false,
          'horario_limite': horaActual.add(const Duration(hours: 1)).toIso8601String(),
        });
        horaActual = horaActual.add(Duration(hours: frec));
      }

      // C. Inserción masiva
      if (recordatorios.isNotEmpty) {
        await supabase.from('recordatorios_medicacion').insert(recordatorios);
      }
      return true;
    } catch(e) {
      //debugPrint("Error al agregar tratamiento: $e");
      return false;
    }
  }

}