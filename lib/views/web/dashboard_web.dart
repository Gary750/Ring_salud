import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'new_patient_view.dart';
import 'patient_detail_view.dart';

class DashboardWeb extends StatefulWidget {
  const DashboardWeb({super.key});

  @override
  State<DashboardWeb> createState() => _DashboardWebState();
}

class _DashboardWebState extends State<DashboardWeb> {
  final supabase = Supabase.instance.client;

  // ==============================================================
  // FUNCIÓN PARA OBTENER LOS PACIENTES REALES DE LA BASE DE DATOS
  // ==============================================================
  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    try {
      // 1. Saber qué médico está logueado
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      // 2. Obtener su ID numérico
      final doctorData = await supabase
          .from('medico')
          .select('id_medico')
          .eq('correo', userEmail)
          .single();

      final int doctorId = doctorData['id_medico'];

      // 3. Buscar todos LOS PACIENTES de ese médico
      // Ordenamos por id descendente para ver los más nuevos primero
      final response = await supabase
          .from('paciente')
          .select()
          .eq('id_medico', doctorId)
          .order('id_paciente', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error obteniendo pacientes: $e");
      return [];
    }
  }

  // ==============================================================
  // FUNCIÓN PARA OBTENER EL NOMBRE DEL MÉDICO
  // ==============================================================
  Future<String> _getDoctorName() async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return "Sin sesión";

      final data = await supabase
          .from('medico')
          .select('usuario')
          .eq('correo', userEmail)
          .single();

      return data['usuario'] ?? "Sin usuario";
    } catch (e) {
      return "Error al cargar";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores del Panel Médico
    final sidebarColor = const Color(0xFF041E60); // Azul oscuro del menú
    final bgLight = const Color(0xFFF4F7FC); // Fondo gris claro
    final primaryBlue = const Color(0xFF018BF0); // Azul vibrante

    return Scaffold(
      body: Row(
        children: [
          // ---------------- LADO IZQUIERDO: SIDEBAR ----------------
          Container(
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
                const SizedBox(height: 40),
                _buildMenuItem("Pacientes", Icons.people, true), // Activo
                _buildMenuItem("Historial", Icons.history, false),
                _buildMenuItem("Alertas", Icons.notifications, false),
                _buildMenuItem("Configuración", Icons.settings, false),
                const Spacer(),
                _buildProfileItem(),
              ],
            ),
          ),

          // ---------------- LADO DERECHO: CONTENIDO ----------------
          Expanded(
            child: Container(
              color: bgLight,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Text(
                    "Pacientes",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1F46),
                    ),
                  ),
                  const Text(
                    "Gestiona tus pacientes con tratamiento fijo y supervisa la toma de medicamentos.",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),

                  // Barra de búsqueda y Botón Nuevo Paciente
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                "Buscar por nombre completo o nombre de usuario",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navegar a Nuevo Paciente y recargar la lista al volver
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewPatientView(),
                            ),
                          ).then((value) => setState(() {}));
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text("Nuevo paciente"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- TABLA DE PACIENTES DINÁMICA ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Encabezados
                          const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Paciente",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Enfermedad / Edad",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Contacto",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Emergencia",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Acciones",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),

                          // LISTA REAL (FutureBuilder)
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _fetchPatients(),
                              builder: (context, snapshot) {
                                // 1. Cargando
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                // 2. Error
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "Error al cargar pacientes: ${snapshot.error}",
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                final pacientes = snapshot.data ?? [];

                                // 3. Sin datos
                                if (pacientes.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "No tienes pacientes registrados aún.",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // 4. Construir la lista con los datos
                                return ListView.separated(
                                  itemCount: pacientes.length,
                                  separatorBuilder: (c, i) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    return _buildPatientRowReal(
                                      pacientes[index],
                                    );
                                  },
                                );
                              },
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

  // ==============================================================
  // COMPONENTES DE INTERFAZ
  // ==============================================================

  Widget _buildMenuItem(String title, IconData icon, bool isActive) {
    return Container(
      color: isActive ? Colors.blue.withOpacity(0.2) : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF021442),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: _getDoctorName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Cargando...",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  }
                  final nombre = snapshot.data ?? "Doctor desconocido";
                  return Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FILA DINÁMICA CON DATOS REALES ---
  Widget _buildPatientRowReal(Map<String, dynamic> paciente) {
    // Extraer datos asegurando que no sean nulos
    final String nombre = paciente['nombre'] ?? 'Sin nombre';
    final String usuario = paciente['usuario'] ?? 'Sin usuario';
    final String enfermedad = paciente['enfermedad'] ?? 'No especificada';
    final String edad = paciente['edad']?.toString() ?? '-';
    final String telefono = paciente['telefono'] ?? 'No registrado';
    final String telEmergencia =
        paciente['numero_emergencia'] ?? 'No registrado';

    // Status visual por defecto
    Color statusColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // 1. Columna Paciente
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Usr: $usuario",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 2. Columna Enfermedad / Edad
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Activo",
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$enfermedad  ·  $edad años",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          // 3. Columna Contacto (Personal)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_android, size: 14, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    telefono,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Columna Emergencia
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  telEmergencia,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),

          // 5. Botón Ver Detalle
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () {
                // AQUÍ ESTÁ LA MAGIA: Pasamos el mapa completo del paciente
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailView(paciente: paciente),
                  ),
                );
              },
              child: const Text("Ver detalle"),
            ),
          ),
        ],
      ),
    );
  }
}
