import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';

class NewPatientView extends StatefulWidget {
  const NewPatientView({super.key});

  @override
  State<NewPatientView> createState() => _NewPatientViewState();
}

class _NewPatientViewState extends State<NewPatientView> {
  final PatientController _controller = PatientController();

  // Colores extraídos del diseño
  final sidebarColor = const Color(0xFF041E60);
  final bgLight = const Color(0xFFF0F4FA);
  final primaryBlue = const Color(0xFF018BF0);
  final textDark = const Color(0xFF0D1F46);

  @override
  void initState() {
    super.initState();
    // Ya no generamos nada automático, será manual para coincidir con tu preferencia
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- SIDEBAR (Fijo) ----------------
          _buildSidebar(),

          // ---------------- CONTENIDO PRINCIPAL (Scrollable) ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: Título y Breadcrumbs
                  _buildHeader(),

                  const SizedBox(height: 20),

                  Form(
                    key: _controller.formKey,
                    child: Column(
                      children: [
                        // --- TARJETA 1: DATOS BÁSICOS (Actualizada con campos BD) ---
                        _buildSectionCard(
                          title: "1. Datos del paciente",
                          subtitle:
                              "Información personal coincidente con la base de datos.",
                          child: _buildBasicInfoForm(),
                        ),

                        const SizedBox(height: 20),

                        // --- TARJETA 2: MEDICACIÓN ---
                        _buildSectionCard(
                          title: "2. Pauta de medicación",
                          subtitle:
                              "Configura aquí los medicamentos. El paciente solo podrá confirmar tomas.",
                          child: _buildMedicationTable(),
                        ),

                        const SizedBox(height: 20),

                        // --- TARJETA 3: CREDENCIALES (Modificada a Manual) ---
                        _buildSectionCard(
                          title: "3. Credenciales de acceso",
                          subtitle:
                              "Asigne el usuario y contraseña para la base de datos.",
                          child: _buildCredentialsForm(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FOOTER: Botones de Acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Guardar borrador",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          bool success = await _controller.createPatient(
                            context,
                          );
                          if (success && mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save_as),
                        label: const Text("Guardar y activar tratamiento"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  //              WIDGETS DE LA ESTRUCTURA
  // ======================================================

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Rx Panel Médico",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          _buildMenuRow(Icons.people, "Pacientes", true), // Activo
          _buildMenuRow(Icons.history, "Historial", false),
          _buildMenuRow(Icons.notifications, "Alertas", false),
          _buildMenuRow(Icons.settings, "Configuración", false),
        ],
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String text, bool isActive) {
    return Container(
      color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nuevo paciente con tratamiento fijo",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Pacientes",
                  style: TextStyle(color: Colors.blueGrey[400]),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                const Text(
                  "Nuevo paciente",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Paso 1 · 2 · 3",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          tooltip: "Cancelar",
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.blueGrey[400]),
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  // ======================================================
  //              FORMULARIOS INTERNOS
  // ======================================================

  Widget _buildBasicInfoForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildInput(
                "Nombre completo *",
                _controller.nameController,
                "Ej. María Gómez",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildInput("Edad *", _controller.ageController, "68"),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "Diagnóstico principal *",
                _controller.diagnosisController,
                "Ej. Hipertensión",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInput(
                "Teléfono de contacto *",
                _controller.phoneController,
                "+52 55 ...",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- NUEVA FILA: Campos faltantes en la BD ---
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "Correo electrónico *", // <--- Agrega el asterisco visual
                _controller.emailController,
                "Necesario para iniciar sesión",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInput(
                "Número de emergencia *",
                _controller.emergencyPhoneController,
                "Familiar responsable",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildInput(
          "Alergias (Opcional)",
          _controller.allergiesController,
          "Ej. Penicilina",
        ),
      ],
    );
  }

  Widget _buildMedicationTable() {
    return Column(
      children: [
        // Encabezado de tabla simulada
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.blue.withOpacity(0.05),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "  Medicamento",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Dosis",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Frecuencia",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Horarios",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fila de ejemplo (Estática por ahora, para diseño)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "  Enalapril",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 1, child: Text("10 mg")),
              Expanded(flex: 1, child: Text("1 vez al día")),
              Expanded(flex: 1, child: Text("07:30 am")),
            ],
          ),
        ),
        const Divider(),
        // Botón Añadir
        Center(
          child: TextButton.icon(
            onPressed: () {}, // Lógica futura para agregar fila
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Añadir medicamento a la lista"),
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nombre de Usuario *",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.controlNumberController,
                    readOnly: false, // CAMBIO: Ahora es editable
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          Colors.white, // Blanco para indicar que es editable
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const Text(
                    "Nombre de Usuario",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contraseña *",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.passwordController,
                    readOnly: false, // CAMBIO: Ahora es editable
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          Colors.white, // Blanco para indicar que es editable
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    ),
                    validator: (v) =>
                        v!.length < 6 ? "Mín. 6 caracteres" : null,
                  ),
                  const Text(
                    "Contraseña para el acceso.",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Estos datos se guardan directamente en las columnas 'usuario' y 'contraseña' de la tabla Paciente.",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1F46),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          validator: (v) {
            if (label.contains("*") && (v == null || v.isEmpty))
              return "Requerido";
            return null;
          },
        ),
      ],
    );
  }
}
