import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordatoriosController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  int filtroSeleccionado = 0;
  bool cargando = false;
  String? mensajeError;

  List<Map<String, dynamic>> _recordatorios = [];

  List<Map<String, dynamic>> get recordatoriosFiltrados {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    if (filtroSeleccionado == 1) { 
      return _recordatorios.where((r) {
        final f = r["fecha"] as DateTime;
        return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
      }).toList();
    }

    if (filtroSeleccionado == 2) { // Últimos 7 días
      final hace7Dias = hoy.subtract(const Duration(days: 7));
      return _recordatorios.where((r) {
        final f = r["fecha"] as DateTime;
        final fechaRegistro = DateTime(f.year, f.month, f.day);
        return fechaRegistro.isAfter(hace7Dias) || fechaRegistro.isAtSameMomentAs(hace7Dias);
      }).toList();
    }
    return _recordatorios;
  }

  int get totalEnviados => recordatoriosFiltrados.length;
  int get totalConfirmados => recordatoriosFiltrados.where((r) => r["estado"] == "Visto").length;

  Future<void> cargarRecordatorios({int? idPaciente}) async {
    if (cargando) return;

    cargando = true;
    mensajeError = null;
    
    if (hasListeners) notifyListeners();

    try {
      int? targetId = idPaciente;
      if (targetId == null) {
        final user = supabase.auth.currentUser;
        if (user == null) throw "Sesión inválida";
        
        final p = await supabase
            .from('paciente')
            .select('id_paciente')
            .eq('correo', user.email!)
            .maybeSingle();
            
        targetId = p?["id_paciente"];
      }

      if (targetId == null) throw "ID de paciente no encontrado";

      final List<dynamic> data = await supabase
          .from('recordatorios_medicacion')
          .select('fecha_hora_programada, enviado, confirmado, tratamientos!inner(nombre_medicamento, dosis)')
          .eq('tratamientos.id_paciente', targetId)
          .order('fecha_hora_programada', ascending: false);

      _recordatorios = data.map((r) {
        final fecha = DateTime.parse(r["fecha_hora_programada"]);
        final esVisto = r["confirmado"] == true;
        
        return {
          "hora": "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}",
          "titulo": "${r["tratamientos"]["nombre_medicamento"]} ${r["tratamientos"]["dosis"]}",
          "descripcion": "Toma programada",
          "estado": esVisto ? "Visto" : (r["enviado"] == true ? "Enviado" : "Sin respuesta"),
          "fecha": fecha
        };
      }).toList();

    } catch (e) {
      debugPrint("Error de carga en Controller: $e");
      mensajeError = "Error al cargar datos";
    } finally {
      cargando = false;
      if (hasListeners) notifyListeners();
    }
  }

  void cambiarFiltro(int index) {
    filtroSeleccionado = index;
    if (hasListeners) notifyListeners();
  }

  String formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    if (fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day) return "Hoy";
    
    final meses = ["", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];
    return "${fecha.day} de ${meses[fecha.month]} del ${fecha.year}";
  }
}





