class Patient {
  final int idPaciente;
  final String nombre;
  final int edad;
  final String telefono;
  final String correo;
  final String enfermedad;
   final String contrasena;
  final String? alergias;

  Patient({
    required this.idPaciente,
    required this.nombre,
    required this.edad,
    required this.telefono,
    required this.correo,
    required this.enfermedad,
      this.alergias,
this.contrasena = ''  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      idPaciente: map['id_paciente'],
      nombre: map['nombre'],
      edad: map['edad'],
      telefono: map['telefono'],
      correo: map['correo'],
      enfermedad: map['enfermedad'],
      contrasena: map['contrasena'] ?? '',
      alergias: map['alergias'],
    );
  }
}
