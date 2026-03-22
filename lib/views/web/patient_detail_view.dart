import 'package:flutter/material.dart';
import '../../controllers/patient_detail_controller.dart';

class PatientDetailView extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback
  onBack; // Recibe la función para cerrarse y volver al Dashboard

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

  // Colores extraídos de tu diseño
  final bgLight = const Color(0xFFF4F7FC);
  final primaryBlue = const Color(0xFF018BF0);
  final textDark = const Color(0xFF0D1F46);

  @override
  Widget build(BuildContext context) {
    // Es una sub-vista, por lo que usamos SingleChildScrollView en lugar de Scaffold
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER RECUPERADO
          _buildHeader(),
          const SizedBox(height: 20),

          // 2. ESTRUCTURA DE 2 COLUMNAS
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

  // ==============================================================
  // HEADER (RECUPERADO CON SUS BOTONES)
  // ==============================================================
  Widget _buildHeader() {
    final nombre = widget.paciente['nombre'] ?? 'Sin nombre';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Detalle de paciente",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Activo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),

            // Botón Volver a lista
            TextButton.icon(
              onPressed: widget.onBack, // <--- Cierra la vista suavemente
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              label: const Text("Volver a lista"),
            ),
            const SizedBox(width: 15),

            // BOTÓN RECUPERADO: Ver alertas
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Funcionalidad futura de alertas
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text("Ver alertas de este paciente"),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          "Pacientes · $nombre",
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Revisa la información clínica, edita la pauta de medicación y sigue las confirmaciones desde la app del paciente.",
          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
        ),
      ],
    );
  }

  // ==============================================================
  // TARJETAS (RECUPERADAS CON TODA SU INFORMACIÓN)
  // ==============================================================

  // 1. Ficha del Paciente
  Widget _buildPatientInfoCard() {
    final paciente = widget.paciente;
    final alergias = paciente['alergias'] ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ficha del paciente",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Text(
                "ID - ${paciente['id_paciente'] ?? '-'}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Text(
            "Datos clínicos de referencia. El paciente solo los puede leer desde su app.",
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
          const Divider(height: 30),

          Row(
            children: [
              Expanded(
                child: _buildInfoData(
                  "Nombre completo",
                  paciente['nombre'] ?? '-',
                ),
              ),
              Expanded(
                child: _buildInfoData(
                  "Edad",
                  "${paciente['edad'] ?? '-'} años",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoData(
                  "Diagnóstico principal",
                  paciente['enfermedad'] ?? '-',
                ),
              ),
              Expanded(
                child: _buildInfoData(
                  "Teléfono de contacto",
                  paciente['telefono'] ?? '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ALERGIAS CON ESTILO DE BADGE ROJO (Como en tu diseño)
          const Text(
            "Alergias registradas",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          if (alergias.isNotEmpty && alergias.toLowerCase() != 'ninguna')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alergias,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Text("Ninguna", style: TextStyle(fontSize: 16)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 2. Información de Acceso
  Widget _buildAccessInfoCard() {
    final paciente = widget.paciente;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Información de acceso",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          _buildInfoData("Nombre de usuario", paciente['usuario'] ?? '-'),
          const Text(
            "Usa este nombre para identificar al paciente en la app.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 11),
          ),
          const SizedBox(height: 20),

          const Text(
            "Contraseña",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                _obscurePassword ? "••••••••" : (paciente['contrasena'] ?? '-'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Text(_obscurePassword ? "Ver" : "Ocultar"),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            "En la app del paciente se muestra solo una pista.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 11),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // 3. Tabla de Medicamentos
  Widget _buildMedicationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Horarios de medicamentos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const Text(
            "Solo el médico puede cambiar estos datos. El paciente solo confirma tomas.",
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
          const Divider(height: 30),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _controller.fetchTreatments(widget.paciente['id_paciente']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );

              final tratamientos = snapshot.data ?? [];

              if (tratamientos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No hay tratamientos activos en este momento.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Medicamento",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Dosis",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Frecuencia",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Fecha Inicio",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Fecha Fin",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...tratamientos.map(
                    (t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              t['nombre_medicamento'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Text(t['dosis'] ?? '-')),
                          Expanded(
                            flex: 2,
                            child: Text("Cada ${t['frecuencia_horas']}h"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              t['fecha_inicio']?.split('T')[0] ?? '-',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              t['fecha_fin']?.split('T')[0] ?? '-',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // BOTONES ACTIVOS AQUÍ
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () async {
                  bool confirmar =
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("¿Detener tratamiento?"),
                          content: const Text(
                            "Se cancelarán todos los recordatorios futuros. El historial pasado se conservará.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Sí, detener",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirmar) {
                    bool exito = await _controller.deactivateAllTreatments(
                      widget.paciente['id_paciente'],
                    );
                    if (exito) setState(() {});
                  }
                },
                child: const Text(
                  "Desactivar tratamiento",
                  style: TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(width: 15),

              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoNuevaPauta(),
                icon: const Icon(Icons.add),
                label: const Text("Añadir medicamento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Historial de Confirmaciones
  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Historial de confirmaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              // BOTÓN RECUPERADO: Filtro "Hoy / Últimos 7 días"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Hoy · 7 días",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            "Listado cronológico de tomas confirmadas o no desde la app.",
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
          const Divider(height: 30),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _controller.fetchHistory(widget.paciente['id_paciente']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final historial = snapshot.data ?? [];

              if (historial.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Aún no hay tomas registradas.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: historial.map((recordatorio) {
                  final tratamiento = recordatorio['tratamientos'] ?? {};
                  final DateTime fechaP = DateTime.parse(
                    recordatorio['fecha_hora_programada'],
                  ).toLocal();
                  final bool conf = recordatorio['confirmado'] ?? false;
                  final List confirmaciones =
                      recordatorio['historial_confirmaciones'] ?? [];
                  String est = conf ? 'Tomado' : 'No confirmado';
                  if (confirmaciones.isNotEmpty)
                    est = confirmaciones.first['estado'] ?? est;
                  else if (!conf &&
                      fechaP
                          .add(const Duration(hours: 1))
                          .isBefore(DateTime.now()))
                    est = 'Omitido';

                  return _buildHistoryRow(
                    fecha:
                        "${fechaP.day}/${fechaP.month} · ${fechaP.hour}:${fechaP.minute.toString().padLeft(2, '0')}",
                    medicina:
                        "${tratamiento['nombre_medicamento']} · ${tratamiento['dosis']}",
                    estado: est,
                    confirmado: conf,
                  );
                }).toList(),
              );
            },
          ),

          const Divider(),
          // TEXTO INFERIOR RECUPERADO
          TextButton(
            onPressed: () {},
            child: const Text(
              "Ver detalle en módulo de Historial",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // MODAL PARA AÑADIR MEDICAMENTOS (FUNCIONAL)
  // ==============================================================
  void _mostrarDialogoNuevaPauta() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final daysCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir medicamento"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Medicamento",
                    hintText: "Ej. Paracetamol",
                  ),
                  validator: (v) => v!.isEmpty ? "Requerido" : null,
                ),
                TextFormField(
                  controller: doseCtrl,
                  decoration: const InputDecoration(
                    labelText: "Dosis",
                    hintText: "Ej. 500mg",
                  ),
                  validator: (v) => v!.isEmpty ? "Requerido" : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: freqCtrl,
                        decoration: const InputDecoration(
                          labelText: "Frec. (Horas)",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "*" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: daysCtrl,
                        decoration: const InputDecoration(
                          labelText: "Duración (Días)",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "*" : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  bool exito = await _controller.addSingleTreatment(
                    widget.paciente['id_paciente'],
                    nameCtrl.text,
                    doseCtrl.text,
                    int.parse(freqCtrl.text),
                    int.parse(daysCtrl.text),
                  );
                  if (exito) setState(() {});
                }
              },
              child: const Text("Guardar cambios"),
            ),
          ],
        );
      },
    );
  }

  // --- Helpers visuales ---
  Widget _buildHistoryRow({
    required String fecha,
    required String medicina,
    required String estado,
    required bool confirmado,
  }) {
    Color badgeColor = confirmado
        ? (estado.toLowerCase().contains("retraso")
              ? Colors.orange
              : Colors.green)
        : (estado.toLowerCase() == "omitido" ? Colors.redAccent : Colors.grey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              fecha,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicina,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
