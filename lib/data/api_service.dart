import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getPacienteActual() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("No hay usuario logeado");
      return null;
    }

    try {
      final data = await supabase
          .from('paciente')
          .select()
          .eq('correo', user.email!) 
          .single();

      return data;
    } catch (e) {
      print("Error obteniendo paciente: $e");
      return null;
    }
  }
}