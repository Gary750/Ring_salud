import 'package:flutter/material.dart';
import '../../controllers/patient_detail_controller.dart';
import 'patient_alerts_view.dart';

class PatientDetailView extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onBack;

  const PatientDetailView({
    super.key,
    required this.paciente,
    required this.onBack,
  });

  @override
  State<PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<PatientDetailView> {
  final PatientDetailController _controller = PatientDetailController();
  bool _obscurePassword = true;
  bool _showingAlerts = false; 

  static const Color _primaryBlue = Color(0xFF018BF0);
  static const Color _textDark    = Color(0xFF0D1F46);

  Future<List<Map<String, dynamic>>> _treatmentsFuture = Future.value([]);
  Future<List<Map<String, dynamic>>> _historyFuture    = Future.value([]);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final id = widget.paciente['id_paciente'];
    setState(() {
      _treatmentsFuture = _controller.fetchTreatments(id);
      _historyFuture    = _controller.fetchHistory(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingAlerts) {
      return PatientAlertsView(
        paciente: widget.paciente,
        onBack: () => setState(() => _showingAlerts = false),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildPatientInfoCard(),
                    const SizedBox(height: 20),
                    _buildMedicationsCard(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildAccessInfoCard(),
                    const SizedBox(height: 20),
                    _buildHistoryCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final nombre = widget.paciente['nombre'] ?? 'Sin nombre';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Detalle de paciente",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: const Text("Activo", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              label: const Text("Volver a lista"),
            ),
            const SizedBox(width: 15),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showingAlerts = true); 
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text("Ver alertas de este paciente"),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text("Pacientes · $nombre", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        const Text(
          "Revisa la información clínica, edita la pauta de medicación y sigue las confirmaciones desde la app del paciente.",
          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard() {
    final paciente = widget.paciente;
    final alergias = paciente['alergias'] ?? '';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ficha del paciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              Text("ID - ${paciente['id_paciente'] ?? '-'}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text("Datos clínicos de referencia. El paciente solo los puede leer desde su app.",
              style: TextStyle(color: Colors.blue, fontSize: 12)),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(child: _buildInfoData("Nombre completo", paciente['nombre'] ?? '-')),
              Expanded(child: _buildInfoData("Edad", "${paciente['edad'] ?? '-'} años")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoData("Diagnóstico principal", paciente['enfermedad'] ?? '-')),
              Expanded(child: _buildInfoData("Teléfono de contacto", paciente['telefono'] ?? '-')),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Alergias registradas",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 5),
          if (alergias.isNotEmpty && alergias.toLowerCase() != 'ninguna')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
              child: Text(alergias, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            const Text("Ninguna", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccessInfoCard() {
    final paciente = widget.paciente;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Información de acceso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          _buildInfoData("Nombre de usuario", paciente['usuario'] ?? '-'),
          const Text("Usa este nombre para identificar al paciente en la app.",
              style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
          const SizedBox(height: 20),
          const Text("Contraseña",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                _obscurePassword ? "••••••••" : (paciente['contrasena'] ?? '-'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Text(_obscurePassword ? "Ver" : "Ocultar"),
              ),
            ],
          ),
          const Text("En la app del paciente se muestra solo una pista.",
              style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildMedicationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Horarios de medicamentos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          const Text("Solo el médico puede cambiar estos datos. El paciente solo confirma tomas.",
              style: TextStyle(color: Colors.blue, fontSize: 12)),
          const Divider(height: 30),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _treatmentsFuture, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Error al cargar tratamientos.", style: TextStyle(color: Colors.red)),
                );
              }
              final tratamientos = snapshot.data ?? [];
              if (tratamientos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No hay tratamientos activos en este momento.", style: TextStyle(color: Colors.grey)),
                );
              }
              return Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 3, child: Text("Medicamento", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 3, child: Text("Dosis",       style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text("Frec.",       style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 3, child: Text("Periodo",     style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text("Estado",      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 1, child: Icon(Icons.delete, color: Colors.blue, size: 16)), 
                    ],
                  ),
                  const Divider(),
                  
                  ...tratamientos.map((t) {
                    final fechaFin = DateTime.parse(t['fecha_fin']).toLocal();
                    final isActivo = fechaFin.isAfter(DateTime.now());
                    
                    final inicioStr = t['fecha_inicio']?.split('T')[0] ?? '-';
                    final finStr = t['fecha_fin']?.split('T')[0] ?? '-';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(t['nombre_medicamento'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text(t['dosis'] ?? '-')),
                          Expanded(flex: 2, child: Text("Cada ${t['frecuencia_horas']}h")),
                          Expanded(flex: 3, child: Text("$inicioStr al $finStr", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
                          
                          Expanded(
                            flex: 2, 
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActivo ? Colors.green.shade50 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(
                                  isActivo ? "Activo" : "Inactivo", 
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActivo ? Colors.green : Colors.grey.shade600)
                                )
                              ),
                            )
                          ),
                          
                          SizedBox(
                            width: 40,
                            child: isActivo ? IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                              tooltip: "Detener medicamento",
                              onPressed: () => _desactivarIndividual(t['id_tratamiento'], t['nombre_medicamento']),
                            ) : null,
                          )
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("¿Detener TODO el tratamiento?"),
                      content: const Text("Se cancelarán todos los medicamentos y recordatorios futuros."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Sí, detener todos", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ) ?? false;

                  if (confirmar) {
                    final exito = await _controller.deactivateAllTreatments(widget.paciente['id_paciente']);
                    if (exito && mounted) _refreshData();
                  }
                },
                child: const Text("Desactivar TODO", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoNuevaPauta(),
                icon: const Icon(Icons.add),
                label: const Text("Añadir medicamento"),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _desactivarIndividual(int idTratamiento, String nombreMed) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Detener $nombreMed?"),
        content: const Text("Se cancelarán los recordatorios futuros únicamente de este medicamento. El historial pasado se conservará."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, detener", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      final exito = await _controller.deactivateAllTreatments(idTratamiento);
      if (exito && mounted) _refreshData();
    }
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("Historial de confirmaciones",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.filter_alt_outlined, size: 16, color: Colors.blue),
                    SizedBox(width: 5),
                    Text("Hoy · 7 días", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text("Listado cronológico de tomas confirmadas o no desde la app.",
              style: TextStyle(color: Colors.blue, fontSize: 12)),
          const Divider(height: 30),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _historyFuture, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Error al cargar historial.", style: TextStyle(color: Colors.red)),
                );
              }
              final historial = snapshot.data ?? [];
              if (historial.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Aún no hay tomas registradas.", style: TextStyle(color: Colors.grey)),
                );
              }
              return Column(
                children: historial.map((recordatorio) {
                  final tratamiento = recordatorio['tratamientos'] ?? {};
                  final DateTime fechaP = DateTime.parse(recordatorio['fecha_hora_programada']).toLocal();
                  final bool conf = recordatorio['confirmado'] ?? false;
                  final List confirmaciones = recordatorio['historial_confirmaciones'] ?? [];
                  String est = conf ? 'Tomado' : 'No confirmado';
                  if (confirmaciones.isNotEmpty) {
                    est = confirmaciones.first['estado'] ?? est;
                  } else if (!conf && fechaP.add(const Duration(hours: 1)).isBefore(DateTime.now())) {
                    est = 'Omitido';
                  }
                  return _buildHistoryRow(
                    fecha: "${fechaP.day}/${fechaP.month} · ${fechaP.hour}:${fechaP.minute.toString().padLeft(2, '0')}",
                    medicina: "${tratamiento['nombre_medicamento']} · ${tratamiento['dosis']}",
                    estado: est,
                    confirmado: conf,
                  );
                }).toList(),
              );
            },
          ),

          const Divider(),
        ],
      ),
    );
  }

void _mostrarDialogoNuevaPauta() async {
    // 1. Abrimos el nuevo widget que vamos a crear y esperamos su respuesta
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando afuera accidentalmente
      builder: (context) => const _DialogoNuevaPautaWidget(),
    );

    // 2. Si el usuario canceló, result será nulo. Si guardó, procesamos:
    if (result != null && mounted) {
      final idPac = widget.paciente['id_paciente'];

      final exito = await _controller.addSingleTreatment(
        idPac,
        result['name'],
        result['dose'],
        result['frec'],
        result['dias'],
      );
      
      if (exito && mounted) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${result['name']} añadido"), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildHistoryRow({
    required String fecha,
    required String medicina,
    required String estado,
    required bool confirmado,
  }) {
    final Color badgeColor = confirmado
        ? (estado.toLowerCase().contains("retraso") ? Colors.orange : Colors.green)
        : (estado.toLowerCase() == "omitido" ? Colors.redAccent : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(fecha, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicina, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                  child: Text(estado.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoData(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 16, color: _textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _DialogoNuevaPautaWidget extends StatefulWidget {
  const _DialogoNuevaPautaWidget();

  @override
  State<_DialogoNuevaPautaWidget> createState() => _DialogoNuevaPautaWidgetState();
}

class _DialogoNuevaPautaWidgetState extends State<_DialogoNuevaPautaWidget> {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final formKey  = GlobalKey<FormState>();

  @override
  void dispose() {
    // Flutter llamará a esto de forma 100% segura cuando la animación termine
    nameCtrl.dispose();
    doseCtrl.dispose();
    freqCtrl.dispose();
    daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Añadir medicamento"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Medicamento", hintText: "Ej. Paracetamol"),
              validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
            ),
            TextFormField(
              controller: doseCtrl,
              decoration: const InputDecoration(labelText: "Dosis", hintText: "Ej. 500mg"),
              validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: freqCtrl,
                    decoration: const InputDecoration(labelText: "Frec. (Horas)"),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return "Debe ser > 0";
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: daysCtrl,
                    decoration: const InputDecoration(labelText: "Duración (Días)"),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return "Debe ser > 0";
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            
            // Enviamos los datos a la pantalla principal y cerramos
            Navigator.pop(context, {
              'name': nameCtrl.text,
              'dose': doseCtrl.text,
              'frec': int.parse(freqCtrl.text),
              'dias': int.parse(daysCtrl.text),
            });
          },
          child: const Text("Guardar cambios"),
        ),
      ],
    );
  }
}