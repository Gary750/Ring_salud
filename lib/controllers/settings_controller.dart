import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsController {
  final supabase = Supabase.instance.client;

  // 1. Obtener los datos actuales del doctor logueado
  Future<Map<String, dynamic>?> fetchDoctorData() async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return null;

      final data = await supabase
          .from('medico')
          .select()
          .eq('correo', userEmail)
          .single();
          
      return data;
    } catch (e) {
      debugPrint("Error al cargar perfil del médico: $e");
      return null;
    }
  }

  // 2. Actualizar los datos básicos del doctor
  Future<bool> updateDoctorProfile(int idMedico, String nombre, String telefono) async {
    try {
      await supabase.from('medico').update({
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        // Si tienes columnas para 'especialidad' o 'cedula' en tu BD, agrégalas aquí
      }).eq('id_medico', idMedico);
      
      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil: $e");
      return false;
    }
  }

  // 3. Cerrar sesión
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}