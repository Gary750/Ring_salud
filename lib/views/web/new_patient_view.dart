import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';

class NewPatientView extends StatefulWidget {
  final VoidCallback onBack;

  const NewPatientView({super.key, required this.onBack});

  @override
  State<NewPatientView> createState() => _NewPatientViewState();
}

class _NewPatientViewState extends State<NewPatientView> {
  final PatientController _controller = PatientController();

  // ✅ Constantes estáticas
  static const Color _primaryBlue = Color(0xFF018BF0);
  static const Color _textDark    = Color(0xFF0D1F46);

  @override
  void initState() {
    super.initState();
    _controller.addTreatment();
    _cargarBorrador();
  }

  // ✅ mounted verificado antes de setState
  void _cargarBorrador() async {
    await _controller.loadDraft();
    if (mounted) setState(() {});
  }

  // ✅ dispose del controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          Form(
            key: _controller.formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  title: "1. Datos del paciente",
                  subtitle: "Completa la información básica del paciente. Los campos marcados con * son obligatorios.",
                  child: _buildBasicInfoForm(),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "2. Pauta de medicación",
                  subtitle: "Configura aquí los medicamentos. El paciente solo podrá confirmar tomas.",
                  child: _buildMedicationTable(),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "3. Credenciales de acceso",
                  subtitle: "Gestiona el usuario y contraseña que el paciente usará para acceder a la app móvil.",
                  child: _buildCredentialsForm(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await _controller.saveDraft();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Borrador guardado. Puedes volver más tarde."),
                        backgroundColor: Colors.blueGrey,
                      ),
                    );
                    widget.onBack();
                  }
                },
                child: const Text("Guardar borrador", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  bool success = await _controller.createPatient(context);
                  if (success && mounted) widget.onBack();
                },
                icon: const Icon(Icons.save_as),
                label: const Text("Guardar y activar tratamiento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
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

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nuevo paciente con tratamiento fijo",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text("Pacientes", style: TextStyle(color: Colors.blueGrey[400])),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                const Text("Nuevo paciente", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                  child: const Text("Paso 1 · 2 · 3", style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(onPressed: widget.onBack, icon: const Icon(Icons.close), tooltip: "Cancelar"),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.blueGrey[400])),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildInput("Nombre completo *", _controller.nameController, "Ej. María Gómez"),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              // ✅ Validación numérica para edad
              child: _buildInput("Edad *", _controller.ageController, "68", inputType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildInput("Diagnóstico principal *", _controller.diagnosisController, "Ej. Hipertensión")),
            const SizedBox(width: 20),
            Expanded(
              // ✅ Validación numérica para teléfono
              child: _buildInput("Teléfono de contacto *", _controller.phoneController, "+52 55 ...", inputType: TextInputType.phone),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              // ✅ Validación de formato email
              child: _buildInput("Correo electrónico *", _controller.emailController, "Necesario para notificaciones", inputType: TextInputType.emailAddress),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInput("Número de emergencia *", _controller.emergencyPhoneController, "Familiar responsable", inputType: TextInputType.phone),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInput("Alergias (Opcional)", _controller.allergiesController, "Ej. Penicilina"),
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
              Expanded(flex: 2, child: Text("Dosis",          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              Expanded(flex: 2, child: Text("Frec. (Horas)",  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              Expanded(flex: 2, child: Text("Duración (Días)",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              SizedBox(width: 40),
            ],
          ),
        ),

        ..._controller.treatments.asMap().entries.map((entry) {
          int index        = entry.key;
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
                    // ✅ Valida que frec sea > 0 para evitar loop infinito
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return "Debe ser > 0";
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: form.endDateController,
                    decoration: _tableInputDeco("Ej. 7"),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? "#" : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _controller.removeTreatment(index)),
                ),
              ],
            ),
          );
        }),

        const Divider(),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _controller.addTreatment()),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Añadir medicamento a la lista"),
          ),
        ),
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
            Expanded(child: _buildInput("Usuario *", _controller.usernameController, "Ej. mgomez68")),
            const SizedBox(width: 30),
            // ✅ obscureText activado para la contraseña
            Expanded(child: _buildInput("Contraseña *", _controller.passwordController, "••••••••", obscureText: true)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Estas credenciales se usarán para que el paciente acceda a la app móvil. Asegúrate de que sean únicas y fáciles de recordar para el paciente.",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Parámetros opcionales: obscureText, inputType, validador por tipo
  Widget _buildInput(
    String label,
    TextEditingController controller,
    String hint, {
    bool obscureText           = false,
    TextInputType inputType    = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            // ✅ Validaciones por tipo de campo
            if (inputType == TextInputType.emailAddress && v != null && v.isNotEmpty) {
              if (!v.contains('@') || !v.contains('.')) return "Correo inválido";
            }
            if (inputType == TextInputType.number && v != null && v.isNotEmpty) {
              if (int.tryParse(v) == null) return "Solo números";
            }
            return null;
          },
        ),
      ],
    );
  }
}