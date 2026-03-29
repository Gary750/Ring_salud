class MedicationTask {
  final int idRecordatorio;
  final String time;
  final String name;
  final String dose;
  final String frequency;
  String status;

  MedicationTask({
    required this.idRecordatorio,
    required this.time,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.status,
  });

  factory MedicationTask.fromMap(Map<String, dynamic> map) {
    return MedicationTask(
      idRecordatorio: map['id_recordatorio'],
      time: map['hora'],
      name: map['medicamento'],
      dose: map['dosis'],
      frequency: map['frecuencia'],
      status: map['confirmado'] == true ? "confirmado" : "pendiente",
    );
  }
}