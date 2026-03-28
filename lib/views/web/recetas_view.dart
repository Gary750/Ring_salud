import 'package:flutter/material.dart';
import '../../controllers/recetas_controller.dart';

class RecetasView extends StatefulWidget {
  const RecetasView({super.key});

  @override
  State<RecetasView> createState() => _RecetasViewState();
}

class _RecetasViewState extends State<RecetasView> {
  final RecetasController _controller = RecetasController();
  
  final textDark = const Color(0xFF0D1F46);
  final primaryBlue = const Color(0xFF018BF0);

  // Controladores de texto
  final edadCtrl = TextEditingController();
  final sexoCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final tallaCtrl = TextEditingController();
  final tempCtrl = TextEditingController();
  final taCtrl = TextEditingController();
  final fcCtrl = TextEditingController();
  final spo2Ctrl = TextEditingController();
  final alergiasCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  // Variables de estado
  List<Map<String, dynamic>> _pacientes = [];
  int? _selectedPacienteId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Ponemos la fecha de hoy por defecto (Formato YYYY-MM-DD que pide SQL)
    fechaCtrl.text = DateTime.now().toIso8601String().split('T')[0];
    
    final pacientes = await _controller.fetchPacientesActivos();
    if (mounted) {
      setState(() {
        _pacientes = pacientes;
        _isLoading = false;
      });
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _selectedPacienteId = null;
      edadCtrl.clear();
      sexoCtrl.clear();
      pesoCtrl.clear();
      tallaCtrl.clear();
      tempCtrl.clear();
      taCtrl.clear();
      fcCtrl.clear();
      spo2Ctrl.clear();
      alergiasCtrl.clear();
      descripcionCtrl.clear();
      fechaCtrl.text = DateTime.now().toIso8601String().split('T')[0];
    });
  }

  Future<void> _guardarReceta() async {
    if (_selectedPacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor, selecciona un paciente."), backgroundColor: Colors.red));
      return;
    }
    if (descripcionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La receta no puede ir en blanco."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);

    final exito = await _controller.guardarReceta(
      idPaciente: _selectedPacienteId!,
      fecha: fechaCtrl.text,
      edad: edadCtrl.text,
      sexo: sexoCtrl.text,
      peso: pesoCtrl.text,
      talla: tallaCtrl.text,
      temperatura: tempCtrl.text,
      tensionArterial: taCtrl.text,
      frecuenciaCardiaca: fcCtrl.text,
      spo2: spo2Ctrl.text,
      alergias: alergiasCtrl.text,
      descripcion: descripcionCtrl.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Receta guardada exitosamente!"), backgroundColor: Colors.green));
        _limpiarFormulario();
        // TODO: Aquí a futuro llamaremos a la función para imprimir el PDF
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar la receta."), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    edadCtrl.dispose();
    sexoCtrl.dispose();
    pesoCtrl.dispose();
    tallaCtrl.dispose();
    tempCtrl.dispose();
    taCtrl.dispose();
    fcCtrl.dispose();
    spo2Ctrl.dispose();
    alergiasCtrl.dispose();
    fechaCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 850,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRecetaHeader(),
                  const Divider(thickness: 2, color: Colors.black87),
                  const SizedBox(height: 10),
                  _buildPatientDataForm(),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2, color: Colors.black87),
                  const SizedBox(height: 20),
                  _buildPrescriptionBody(),
                  const SizedBox(height: 40),
                  _buildRecetaFooter(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _limpiarFormulario,
                  icon: const Icon(Icons.clear),
                  label: const Text("Limpiar"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _guardarReceta,
                  icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.print),
                  label: Text(_isSaving ? "Guardando..." : "Guardar Receta"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS DE LA VISTA
  // ==========================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Emisión de Recetas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 5),
        const Text("Llena los datos para generar una receta médica digital y guardarla en el historial.", style: TextStyle(color: Colors.blue, fontSize: 13)),
      ],
    );
  }

  Widget _buildRecetaHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.medical_services_outlined, size: 60, color: Colors.black87),
        const Expanded(
          child: Column(
            children: [
              Text("UNIDAD MÉDICA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('"NUESTRO SEÑOR DE LAS MARAVILLAS"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 5),
              Text("Dr. Martín Trigueros Vixxuett", style: TextStyle(fontFamily: 'cursive', fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("UNIVERSIDAD AUTONOMA DEL ESTADO DE HIDALGO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text("MEDICINA GENERAL - CIRUGIA - PARTOS - NIÑOS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text("R.F.C. TIVM-660102-A82   CEDULA PROFESIONAL 1890573", style: TextStyle(fontSize: 10)),
              Text("S.S.A: AF 02224-07", style: TextStyle(fontSize: 10)),
              SizedBox(height: 10),
              Text("MEDICO CIRUJANO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        const Icon(Icons.health_and_safety_outlined, size: 60, color: Colors.black87),
      ],
    );
  }

  Widget _buildPatientDataForm() {
    return Column(
      children: [
        Row(
          children: [
            const Text("Nombre del paciente:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedPacienteId,
                hint: const Text("Seleccione un paciente"),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 4),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
                items: _pacientes.map((p) => DropdownMenuItem<int>(
                  value: p['id_paciente'],
                  child: Text(p['nombre']),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPacienteId = val;
                    // Autocompletar datos si existen
                    final p = _pacientes.firstWhere((p) => p['id_paciente'] == val);
                    edadCtrl.text = p['edad']?.toString() ?? '';
                    alergiasCtrl.text = p['alergias'] ?? 'Ninguna';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildFormRow("Edad:", edadCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("Sexo:", sexoCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("Peso:", pesoCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("Talla:", tallaCtrl)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildFormRow("Temp:", tempCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("T/A:", taCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("FC:", fcCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _buildFormRow("SpO2:", spo2Ctrl)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(flex: 2, child: _buildFormRow("Glucosa:", TextEditingController())), // No estaba en la BD, lo dejo suelto visualmente o puedes agregarlo a la bd
            const SizedBox(width: 15),
            Expanded(flex: 4, child: _buildFormRow("Alergias:", alergiasCtrl)),
            const SizedBox(width: 15),
            Expanded(flex: 2, child: _buildFormRow("Fecha:", fechaCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildFormRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Prescripción e Indicaciones:", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        TextField(
          controller: descripcionCtrl,
          maxLines: 15,
          decoration: InputDecoration(
            hintText: "Escriba aquí los medicamentos, dosis y frecuencia...",
            hintStyle: TextStyle(color: Colors.grey.shade300),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue.shade300)),
            filled: true,
            fillColor: Colors.blueGrey.shade50.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildRecetaFooter() {
    return const Column(
      children: [
        Divider(thickness: 2, color: Colors.black87),
        SizedBox(height: 10),
        Text("CONSULTA DE LUNES A VIERNES DE 10 A 5 PM, SABADOS DE 8 A 3 PM Y DOMINGOS (HABLAR ANTES)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        SizedBox(height: 5),
        Text("Adolfo López Mateos No. 20 (entre Benito Juárez y Pino Suárez) Col. Centro Tunititlan, Chilcuautla, Hgo. C.P. 42751", style: TextStyle(fontSize: 11)),
        Text("Cel. 7731216932 o 2221103038 NOTA: LLAMAR O MANDAR MENSAJE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}