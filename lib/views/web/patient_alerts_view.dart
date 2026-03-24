import 'package:flutter/material.dart';
import '../../controllers/patient_detail_controller.dart';

class PatientAlertsView extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onBack; // Para regresar al detalle del paciente

  const PatientAlertsView({
    super.key,
    required this.paciente,
    required this.onBack,
  });

  @override
  State<PatientAlertsView> createState() => _PatientAlertsViewState();
}

class _PatientAlertsViewState extends State<PatientAlertsView> {
  final PatientDetailController _controller = PatientDetailController();
  
  static const Color _textDark = Color(0xFF0D1F46);
  static const Color _redAlert = Color(0xFFE53935);

  Future<List<Map<String, dynamic>>> _emergenciesFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _emergenciesFuture = _controller.fetchEmergencies(widget.paciente['id_paciente']);
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
          _buildAlertsTableCard(),
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
            const Text("Registro de Emergencias SOS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
              child: const Text("Alta prioridad", style: TextStyle(color: _redAlert, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              label: const Text("Volver a ficha clínica"),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text("Pacientes · $nombre · Alertas", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        const Text("Historial de veces que el paciente ha presionado el botón de pánico en su aplicación móvil.", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildAlertsTableCard() {
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
          const Text("Historial de Alertas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          const Divider(height: 30),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _emergenciesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error al cargar las emergencias.", style: TextStyle(color: Colors.red)));
              }
              
              final emergencias = snapshot.data ?? [];
              
              if (emergencias.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.green.shade200),
                        const SizedBox(height: 10),
                        const Text("Sin incidentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text("El paciente no ha emitido ninguna alerta de emergencia.", style: TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 2, child: Text("Fecha y Hora", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text("Nivel", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 4, child: Text("Mensaje del paciente", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text("Llamada a familiar", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                  const Divider(),
                  ...emergencias.map((e) => _buildEmergencyRow(e)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyRow(Map<String, dynamic> emergencia) {
    // Formatear Fecha
    String fechaStr = "Fecha desconocida";
    if (emergencia['fecha_evento'] != null) {
      final date = DateTime.parse(emergencia['fecha_evento']).toLocal();
      fechaStr = "${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    // Datos
    final mensaje = emergencia['mensaje_medico'] ?? 'Sin mensaje adicional';
    final bool llamoFamiliar = emergencia['llamada_familiar'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(fechaStr, style: const TextStyle(fontWeight: FontWeight.bold))),
          
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _redAlert, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text("SOS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )),
          
          Expanded(flex: 4, child: Text('"$mensaje"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey))),
          
          Expanded(flex: 2, child: Row(
            children: [
              Icon(
                llamoFamiliar ? Icons.phone_forwarded : Icons.phone_disabled, 
                size: 16, 
                color: llamoFamiliar ? Colors.orange : Colors.grey
              ),
              const SizedBox(width: 5),
              Text(
                llamoFamiliar ? "Sí se notificó" : "No solicitada", 
                style: TextStyle(color: llamoFamiliar ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)
              ),
            ],
          )),
        ],
      ),
    );
  }
}