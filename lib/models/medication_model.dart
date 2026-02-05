//* Clase para representar una tarea relacionada con la medicación
class MedicationTask {
  final String time; //! Hora de la tarea
  final String name; //! Nombre de la medicación
  final String dose; //! Dosis de la medicación
  final String frequency; //! Frecuencia de la medicación
  final String status; //! Estado de la tarea (completada o pendiente)

  MedicationTask({
    required this.time,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.status,
  });
}
