import 'package:flutter/material.dart';
import '../../controllers/patient_detail_controller.dart';

class PatientDetailView extends StatefulWidget {
  final Map<String, dynamic> paciente; // Recibe los datos desde el Dashboard

  const PatientDetailView({super.key, required this.paciente});

  @override
  State<PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<PatientDetailView> {
  final PatientDetailController _controller = PatientDetailController();
  bool _obscurePassword = true; // Para ocultar/mostrar la contraseña

  // Colores de la paleta
  final sidebarColor = const Color(0xFF041E60);
  final bgLight = const Color(0xFFF4F7FC);
  final primaryBlue = const Color(0xFF018BF0);
  final textDark = const Color(0xFF0D1F46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SIDEBAR
          _buildSidebar(),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // ESTRUCTURA DE 2 COLUMNAS (Estilo Dashboard)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- COLUMNA IZQUIERDA (Más ancha 60%) ---
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

                      // --- COLUMNA DERECHA (Más estrecha 40%) ---
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
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HEADER Y SIDEBAR
  // ==============================================================

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Panel Médico",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          Container(
            color: Colors.blue.withOpacity(0.2),
            child: const ListTile(
              leading: Icon(Icons.people, color: Colors.white),
              title: Text(
                "Pacientes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.history, color: Colors.white70),
            title: Text("Historial", style: TextStyle(color: Colors.white70)),
          ),
          const ListTile(
            leading: Icon(Icons.notifications, color: Colors.white70),
            title: Text("Alertas", style: TextStyle(color: Colors.white70)),
          ),
          const ListTile(
            leading: Icon(Icons.settings, color: Colors.white70),
            title: Text("Configuración", style: TextStyle(color: Colors.white70)),
          )
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
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              label: const Text("Volver a lista"),
            ),
            const SizedBox(width: 15),
            OutlinedButton.icon(
              onPressed: () {},
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
      ],
    );
  }

  // ==============================================================
  // TARJETAS (CARDS)
  // ==============================================================

  // 1. Ficha del Paciente (Columna Izquierda Superior)
  Widget _buildPatientInfoCard() {
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
                "Ficha del paciente",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Text(
                "ID del Paciente: ${paciente['id_paciente']}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Text(
            "Datos clínicos de referencia.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 13),
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
          _buildInfoData(
            "Alergias registradas",
            paciente['alergias'] == null || paciente['alergias'].isEmpty
                ? 'Ninguna'
                : paciente['alergias'],
          ),
        ],
      ),
    );
  }

  // 2. Información de Acceso (Columna Derecha Superior)
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
          Text(
            "Información de acceso",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const Text(
            "Credenciales para la app.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 13),
          ),
          const Divider(height: 30),

          _buildInfoData("Usuario", paciente['usuario'] ?? '-'),
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Si modificas la contraseña, avisa al paciente de inmediato.",
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Tabla de Medicamentos (Columna Izquierda Inferior)
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
          Text(
            "Horarios de medicamentos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const Text(
            "Pauta actual extraída de la base de datos.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 13),
          ),
          const Divider(height: 30),

          // FutureBuilder para cargar de la tabla 'tratamientos'
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _controller.fetchTreatments(widget.paciente['id_paciente']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              final tratamientos = snapshot.data ?? [];
              if (tratamientos.isEmpty)
                return const Text("No hay tratamientos registrados.");

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
                          "Frec. (Horas)",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Fecha Inicio",
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
                            flex: 3,
                            child: Text(
                              t['fecha_inicio']?.split('T')[0] ?? '-',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text("Desactivar tratamiento"),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Editar pauta"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Historial (Visual Mockup por ahora)
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
              Text(
                "Historial",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Icon(Icons.filter_list, color: Colors.blue),
            ],
          ),
          const Text(
            "Últimas confirmaciones desde la app.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 13),
          ),
          const Divider(height: 30),

          // Fila simulada 1
          _buildHistoryRow("Hoy · 07:35", "Enalapril · 10 mg", true),
          const Divider(),
          // Fila simulada 2
          _buildHistoryRow("Ayer · 21:55", "Metformina · 850 mg", false),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String fecha, String medicina, bool aTiempo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              fecha,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicina,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: aTiempo ? Colors.blue : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    aTiempo ? "Tomado a tiempo" : "Confirmado con retraso",
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper general ---
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
