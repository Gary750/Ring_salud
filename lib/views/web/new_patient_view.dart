import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';

class NewPatientView extends StatefulWidget {
  final VoidCallback onBack; // Recibe la función para cerrarse y volver al Dashboard

  const NewPatientView({super.key, required this.onBack});

  @override
  State<NewPatientView> createState() => _NewPatientViewState();
}

class _NewPatientViewState extends State<NewPatientView> {
  final PatientController _controller = PatientController();

  // Colores extraídos del diseño
  final primaryBlue = const Color(0xFF018BF0);
  final textDark = const Color(0xFF0D1F46);

  @override
  void initState() {
    super.initState();
    _controller.addTreatment();
    _cargarBorrador();
  }

  void _cargarBorrador() async {
    await _controller.loadDraft();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Vista sin Scaffold, actúa como el contenido derecho del Dashboard
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER RECUPERADO (Título y Breadcrumbs)
          _buildHeader(),
          const SizedBox(height: 20),
          
          Form(
            key: _controller.formKey,
            child: Column(
              children: [
                // --- TARJETA 1: DATOS BÁSICOS ---
                _buildSectionCard(
                  title: "1. Datos del paciente",
                  subtitle: "Información personal coincidente con la base de datos.",
                  child: _buildBasicInfoForm(),
                ),
                const SizedBox(height: 20),

                // --- TARJETA 2: MEDICACIÓN ---
                _buildSectionCard(
                  title: "2. Pauta de medicación",
                  subtitle: "Configura aquí los medicamentos. El paciente solo podrá confirmar tomas.",
                  child: _buildMedicationTable(),
                ),
                const SizedBox(height: 20),

                // --- TARJETA 3: CREDENCIALES ---
                _buildSectionCard(
                  title: "3. Credenciales de acceso",
                  subtitle: "Asigne el usuario y contraseña para la base de datos.",
                  child: _buildCredentialsForm(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // FOOTER RECUPERADO: Botones de Acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await _controller.saveDraft();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Borrador guardado. Puedes volver más tarde."), backgroundColor: Colors.blueGrey)
                    );
                    widget.onBack(); // Cierra la vista
                  }
                },
                child: const Text(
                  "Guardar borrador",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  bool success = await _controller.createPatient(context);
                  if (success && mounted) widget.onBack(); // Cierra la vista al guardar
                },
                icon: const Icon(Icons.save_as),
                label: const Text("Guardar y activar tratamiento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // ======================================================
  //               WIDGETS DE LA ESTRUCTURA
  // ======================================================

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          onPressed: widget.onBack,
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
  //               FORMULARIOS INTERNOS
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
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "Correo electrónico *", 
                _controller.emailController,
                "Necesario para notificaciones",
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.blue.withOpacity(0.05),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text("  Medicamento", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              Expanded(flex: 2, child: Text("Dosis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              Expanded(flex: 2, child: Text("Frec. (Horas)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              Expanded(flex: 2, child: Text("Duración (Días)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              SizedBox(width: 40),
            ],
          ),
        ),
        
        ..._controller.treatments.asMap().entries.map((entry) {
          int index = entry.key;
          TreatmentForm form = entry.value;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: form.nameController,
                    decoration: _tableInputDeco("Ej. Paracetamol"),
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: form.doseController,
                    decoration: _tableInputDeco("Ej. 500mg"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: form.frequencyController,
                    decoration: _tableInputDeco("Ej. 8"),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? "#" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: form.endDateController,
                    decoration: _tableInputDeco("Ej. 7"),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? "#" : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _controller.removeTreatment(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),

        const Divider(),
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _controller.addTreatment();
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Añadir medicamento a la lista"),
          ),
        )
      ],
    );
  }

  InputDecoration _tableInputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildCredentialsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInput("Usuario *", _controller.usernameController, "Ej. mgomez68"),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _buildInput("Contraseña *", _controller.passwordController, "••••••••"),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // CAJA INFORMATIVA RECUPERADA
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
            color: Color(0xFF0D1F46), // Color oscuro específico
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
            if (label.contains("*") && (v == null || v.isEmpty)) return "Requerido";
            return null;
          },
        ),
      ],
    );
  }
}