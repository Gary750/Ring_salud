import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecetasController {
  final supabase = Supabase.instance.client;

  // 1. Obtener la lista de pacientes del doctor actual
  Future<List<Map<String, dynamic>>> fetchPacientesActivos() async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      // Obtenemos el ID del médico
      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final int doctorId = doctorData['id_medico'];

      // Traemos a sus pacientes (necesitamos id, nombre, edad y alergias para autocompletar)
      final response = await supabase
          .from('paciente')
          .select('id_paciente, nombre, edad, alergias')
          .eq('id_medico', doctorId)
          .order('nombre', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error al obtener pacientes: $e");
      return [];
    }
  }

  // 2. Guardar la receta en la base de datos
  Future<bool> guardarReceta({
    required int idPaciente,
    required String fecha,
    required String edad,
    required String sexo,
    required String peso,
    required String talla,
    required String temperatura,
    required String tensionArterial,
    required String frecuenciaCardiaca,
    required String spo2,
    required String alergias,
    required String descripcion,
  }) async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return false;

      // Obtenemos el ID del médico otra vez (por seguridad)
      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final int doctorId = doctorData['id_medico'];

      // Parseamos los enteros (si están vacíos, mandamos null para no romper la BD)
      final int? edadInt = int.tryParse(edad);
      final int? pesoInt = int.tryParse(peso);

      // Insertamos en la tabla (Asumo que tu tabla se llama 'receta' o 'recetas'. Cambia el nombre si es necesario)
      await supabase.from('receta').insert({
        'id_paciente': idPaciente,
        'id_medico': doctorId,
        'fecha': fecha,
        'edad': edadInt,
        'sexo': sexo.isEmpty ? null : sexo,
        'peso': pesoInt,
        'talla': talla.isEmpty ? null : talla,
        'temperatura': temperatura.isEmpty ? null : temperatura,
        'tension_arterial': tensionArterial.isEmpty ? null : tensionArterial,
        'frecuencia_cardiaca': frecuenciaCardiaca.isEmpty ? null : frecuenciaCardiaca,
        'spo2': spo2.isEmpty ? null : spo2,
        'alergias': alergias.isEmpty ? null : alergias,
        'descripcion': descripcion.isEmpty ? null : descripcion,
      });

      return true;
    } catch (e) {
      debugPrint("Error al guardar receta: $e");
      return false;
    }
  }
}