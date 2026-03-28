import 'package:flutter/material.dart';
import '../../controllers/settings_controller.dart';
import 'login_view_web.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController _controller = SettingsController();

  final textDark = const Color(0xFF0D1F46);
  final primaryBlue = const Color(0xFF018BF0);

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController(); // Solo lectura
  final telefonoCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  int? _idMedico;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await _controller.fetchDoctorData();
    if (data != null && mounted) {
      setState(() {
        _idMedico = data['id_medico'];
        nombreCtrl.text = data['nombre'] ?? '';
        correoCtrl.text = data['correo'] ?? '';
        telefonoCtrl.text = data['telefono'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (_idMedico == null) return;

    setState(() => _isSaving = true);
    final exito = await _controller.updateDoctorProfile(
      _idMedico!,
      nombreCtrl.text,
      telefonoCtrl.text,
    );
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? "Perfil actualizado correctamente."
                : "Error al actualizar perfil.",
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    await _controller.logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginViewWeb()), (route) => false);
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configuración",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Administra tu perfil, seguridad y preferencias de la cuenta.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // Contenedor centrado para que no ocupe todo el ancho en pantallas gigantes
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  // --- TARJETA 1: PERFIL ---
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: primaryBlue,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Perfil Profesional",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          _buildTextField(
                            "Nombre Completo (Aparecerá en recetas)",
                            nombreCtrl,
                            Icons.badge_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            "Correo Electrónico (No se puede cambiar)",
                            correoCtrl,
                            Icons.email_outlined,
                            readOnly: true,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            "Teléfono de Contacto",
                            telefonoCtrl,
                            Icons.phone_outlined,
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _guardarCambios,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: const Text("Guardar Cambios"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TARJETA 2: SEGURIDAD ---
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: primaryBlue,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Seguridad",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          const Text(
                            "Para proteger tu cuenta, te recomendamos usar una contraseña segura.",
                          ),
                          const SizedBox(height: 15),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Función en desarrollo..."),
                                ),
                              );
                            },
                            icon: const Icon(Icons.key),
                            label: const Text("Cambiar Contraseña"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TARJETA 3: ZONA DE PELIGRO ---
                  Card(
                    color: const Color(
                      0xFFFFF5F5,
                    ), // Un fondito rojo súper sutil
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cerrar Sesión",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Saldrás del panel de administración médico.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _cerrarSesion,
                            icon: const Icon(Icons.logout),
                            label: const Text("Cerrar Sesión"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para dibujar los TextFields de forma limpia
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
    );
  }
}
