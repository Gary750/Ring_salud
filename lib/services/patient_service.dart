import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

class PatientService {
  final supabase = Supabase.instance.client;

  Future<Patient?> getPatient(int id) async {
    final response = await supabase
        .from('paciente')
        .select()
        .eq('id_paciente', id)
        .single();

    if (response != null) {
      return Patient.fromMap(response);
    }
    return null;
  }
}
