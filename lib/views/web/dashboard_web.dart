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

  int _selectedIndex = 0; 
  String _searchQuery = ""; 
  
  // --- NUEVA VARIABLE: Controla las sub-vistas (Nuevo Paciente / Detalles) ---
  Widget? _vistaSecundaria; 

  // Función para cerrar las sub-vistas y volver a la tabla
  void _cerrarVistaSecundaria() {
    setState(() {
      _vistaSecundaria = null;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      final doctorData = await supabase.from('medico').select('id_medico').eq('correo', userEmail).single();
      final response = await supabase
          .from('paciente')
          .select()
          .eq('id_medico', doctorData['id_medico'])
          .order('id_paciente', ascending: false);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<String> _getDoctorName() async {
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return "Sin sesión";
      final data = await supabase.from('medico').select('usuario').eq('correo', userEmail).single();
      return data['usuario'] ?? "Sin usuario";
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebarColor = const Color(0xFF041E60); 
    final bgLight = const Color(0xFFF4F7FC);      

    return Scaffold(
      backgroundColor: bgLight,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- LADO IZQUIERDO: EL ÚNICO SIDEBAR REAL ----------------
          Container(
            width: 250,
            color: sidebarColor,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text("Panel Médico", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                _buildMenuItem(0, "Pacientes", Icons.people),
                _buildMenuItem(1, "Historial", Icons.history),
                _buildMenuItem(2, "Alertas", Icons.notifications),
                _buildMenuItem(3, "Configuración", Icons.settings),
                
                const Spacer(),
                _buildProfileItem(),
              ],
            ),
          ),

          // ---------------- LADO DERECHO: CONTENIDO CAMBIANTE ----------------
          Expanded(
            child: Container(
              color: bgLight,
              // Si hay una sub-vista activa (Detalle o Nuevo), se muestra. Si no, muestra el Menú Principal.
              child: _vistaSecundaria ?? _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildPacientesView(); 
      case 1: return _buildPlaceholderView("Historial Médico", "Aquí verás el registro de citas pasadas.", Icons.history);
      case 2: return _buildPlaceholderView("Alertas y Emergencias", "Monitor de notificaciones urgentes.", Icons.warning_amber_rounded);
      case 3: return _buildPlaceholderView("Configuración", "Ajustes de tu cuenta.", Icons.settings);
      default: return _buildPacientesView();
    }
  }

  Widget _buildPacientesView() {
    final primaryBlue = const Color(0xFF018BF0);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pacientes", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
          const Text("Gestiona tus pacientes con tratamiento fijo y supervisa la toma de medicamentos.", style: TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre completo o usuario...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // ABRIR SUB-VISTA: Nuevo Paciente
                  setState(() {
                    _vistaSecundaria = NewPatientView(onBack: _cerrarVistaSecundaria);
                  });
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Nuevo paciente"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              )
            ],
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 2, child: Text("Paciente", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text("Enfermedad / Edad", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text("Contacto", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text("Emergencia", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text("Acciones", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const Divider(),
                  
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchPatients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
                        final pacientesBase = snapshot.data ?? [];
                        final pacientesFiltrados = pacientesBase.where((p) {
                          final nombre = (p['nombre'] ?? '').toString().toLowerCase();
                          final usuario = (p['usuario'] ?? '').toString().toLowerCase();
                          return nombre.contains(_searchQuery) || usuario.contains(_searchQuery);
                        }).toList();

                        if (pacientesFiltrados.isEmpty) return const Center(child: Text("No se encontraron pacientes."));

                        return ListView.separated(
                          itemCount: pacientesFiltrados.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) => _buildPatientRowReal(pacientesFiltrados[index]),
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
    );
  }

  Widget _buildPlaceholderView(String titulo, String subtitulo, IconData icono) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 80, color: Colors.blueGrey[200]),
          const SizedBox(height: 20),
          Text(titulo, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
          const SizedBox(height: 10),
          Text(subtitulo, style: const TextStyle(color: Colors.blueGrey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isActive = _selectedIndex == index && _vistaSecundaria == null;
    return Container(
      color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _searchQuery = "";
            _vistaSecundaria = null; // Fuerza el cierre de sub-vistas al usar el menú
          });
        },
      ),
    );
  }
  
  Widget _buildProfileItem() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF021442),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 10),
          FutureBuilder<String>(
            future: _getDoctorName(),
            builder: (context, snapshot) => Text(snapshot.data ?? "Cargando...", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRowReal(Map<String, dynamic> paciente) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(paciente['nombre'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("Usr: ${paciente['usuario']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text("Activo", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text("${paciente['enfermedad']} · ${paciente['edad']} años", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ])),
          Expanded(flex: 2, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.phone_android, size: 14, color: Colors.blue),
              const SizedBox(width: 5),
              Text(paciente['telefono'] ?? '-', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          )),
          Expanded(flex: 2, child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
            const SizedBox(width: 5),
            Text(paciente['numero_emergencia'] ?? '-', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ])),
          Expanded(flex: 1, child: TextButton(
            onPressed: () {
              // ABRIR SUB-VISTA: Detalles del Paciente
              setState(() {
                _vistaSecundaria = PatientDetailView(
                  paciente: paciente, 
                  onBack: _cerrarVistaSecundaria
                );
              });
            }, 
            child: const Text("Ver detalle")
          )),
        ],
      ),
    );
  }
}