//* Modelo de datos para representar la información de un paciente en una aplicación médica.
class Patient {
  final String name; //! Nombre del paciente
  final String controlNumber; //! Número de control
  final String status; //! Estado de salud
  final String diagnosis; //! Diagnóstico médico
  final String nextDose; //! Fecha de la próxima dosis
  final String lastConfirmation; //! Fecha de la última dosis

  Patient({
    required this.name,
    required this.controlNumber,
    required this.status,
    required this.diagnosis,
    required this.nextDose,
    required this.lastConfirmation,
  });
}
