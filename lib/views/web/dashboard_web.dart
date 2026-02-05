import 'package:flutter/material.dart';
import 'package:ring_salud/views/web/new_patient_view.dart';
import '../../models/patient_model.dart';

class DashboardWeb extends StatefulWidget {
  const DashboardWeb({super.key});

  @override
  State<DashboardWeb> createState() => _DashboardWebState();
}

class _DashboardWebState extends State<DashboardWeb> {
  // --- CONTROLADOR SIMULADO (Dentro de la vista por simplicidad) ---
  final List<Patient> patients = [
    Patient(name: "María Gómez", controlNumber: "001-251", status: "Activo", diagnosis: "HTA + DM2", nextDose: "Enalapril 10 mg", lastConfirmation: "Hoy · 07:35"),
    Patient(name: "Carlos Pérez", controlNumber: "001-252", status: "Riesgo", diagnosis: "Insuficiencia cardíaca", nextDose: "Furosemida 40 mg", lastConfirmation: "Retraso > 30 min"),
    Patient(name: "Lucía Fernández", controlNumber: "001-253", status: "Activo", diagnosis: "Asma bronquial", nextDose: "Salbutamol", lastConfirmation: "Ayer · 21:45"),
  ];

  @override
  Widget build(BuildContext context) {
    // Colores del Panel Médico
    final sidebarColor = const Color(0xFF041E60); // Azul oscuro del menú
    final bgLight = const Color(0xFFF4F7FC);      // Fondo gris claro
    final primaryBlue = const Color(0xFF018BF0);  // Azul vibrante

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
                const Text("Rx Panel Médico", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  const Text("Pacientes", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
                  const Text("Gestiona tus pacientes con tratamiento fijo y revisa su adherencia.", style: TextStyle(color: Colors.blueGrey)),
                  const SizedBox(height: 20),

                  // Barra de búsqueda y Botón
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Buscar por nombre o número de control",
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
                          Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => NewPatientView()));
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

                  // Lista de Pacientes (Encabezados y Filas)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Encabezados
                          const Row(
                            children: [
                              Expanded(flex: 2, child: Text("Paciente", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Estado / Diagnóstico", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Próxima toma", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Última confirmación", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Acciones", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(),
                          
                          // Lista dinámica
                          Expanded(
                            child: ListView.separated(
                              itemCount: patients.length,
                              separatorBuilder: (c, i) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _buildPatientRow(patients[index]);
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

  // --- Widgets Auxiliares ---

  Widget _buildMenuItem(String title, IconData icon, bool isActive) {
    return Container(
      color: isActive ? Colors.blue.withOpacity(0.2) : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildProfileItem() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF021442),
      child: const Row(
        children: [
          CircleAvatar(backgroundColor: Colors.blue, child: Text("AL", style: TextStyle(color: Colors.white))),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dra. Ana López", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("Medicina Interna", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPatientRow(Patient p) {
    // Estilos condicionales según estado
    Color statusColor = p.status == 'Activo' ? Colors.green : (p.status == 'Riesgo' ? Colors.orange : Colors.grey);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(p.controlNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(p.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text(p.diagnosis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          Expanded(flex: 2, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(p.nextDose, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
          )),
          Expanded(flex: 2, child: Text(p.lastConfirmation, style: TextStyle(color: p.lastConfirmation.contains("Retraso") ? Colors.red : Colors.grey[700], fontSize: 13))),
          Expanded(flex: 1, child: TextButton(onPressed: (){}, child: const Text("Ver detalle"))),
        ],
      ),
    );
  }
}