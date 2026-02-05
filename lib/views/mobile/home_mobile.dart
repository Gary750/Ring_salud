import 'package:flutter/material.dart';
import '../../models/medication_model.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  // --- CONTROLADOR SIMULADO ---
  final List<MedicationTask> tasks = [
    MedicationTask(time: "08:00 am", name: "Metformina", dose: "500 mg - Despues de comer", frequency: "Todos los días", status: "pendiente"),
    MedicationTask(time: "07:00 pm", name: "Paracetamol", dose: "500 mg - Despues de comer", frequency: "Todos los días", status: "confirmado"),
    MedicationTask(time: "10:00 pm", name: "Omeprazol", dose: "20 mg - Antes de dormir", frequency: "Todos los días", status: "pendiente"),
  ];

  int _currentIndex = 0; // Índice del BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ENCABEZADO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tomas de hoy", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF018BF0), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Hoy · Lunes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text("Sigue esta lista. Si no recuerdas una toma, consulta a tu médico.", style: TextStyle(color: Colors.blueGrey)),
              
              const SizedBox(height: 20),
              
              // --- RESUMEN DE ESTADÍSTICAS ---
              Row(
                children: [
                  Text("${tasks.length}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
                  const SizedBox(width: 8),
                  const Text("tomas programadas", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatRow("1", "confirmada", Colors.black),
                      _buildStatRow("3", "pendientes", Colors.black), // Debería ser dinámico
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),

              // --- LISTA DE TAREAS ---
              ...tasks.map((task) => _buildMedicationCard(task)),
            ],
          ),
        ),
      ),
      
      // --- BARRA DE NAVEGACIÓN ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF018BF0),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.phone_in_talk), label: "Emergencia"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Recordatorios"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  // Widget para el texto pequeño de estadísticas
  Widget _buildStatRow(String number, String label, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF0D1F46), fontSize: 14),
        children: [
          TextSpan(text: number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(text: label),
        ],
      ),
    );
  }

  // Widget Tarjeta de Medicamento
  Widget _buildMedicationCard(MedicationTask task) {
    bool isPending = task.status == 'pendiente';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora y Nombre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
              Text(task.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
            ],
          ),
          const SizedBox(height: 5),
          
          // Dosis e Instrucciones (Centrado visualmente como en la imagen)
          Center(
            child: Column(
              children: [
                Text(task.dose, style: const TextStyle(color: Color(0xFF018BF0), fontWeight: FontWeight.w600)),
                Text("Frecuencia: ${task.frequency}", style: const TextStyle(color: Color(0xFF018BF0))),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Botones de Acción
          Row(
            children: [
              // Chip de estado
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFF6D00), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [Text("Pendiente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 5), Icon(Icons.access_time, color: Colors.white, size: 16)]),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [Text("Confirmado", style: TextStyle(color: Color(0xFF0D1F46), fontWeight: FontWeight.bold)), SizedBox(width: 5), Icon(Icons.check_circle, color: Color(0xFF0D1F46), size: 16)]),
                ),
              
              const SizedBox(width: 15),

              // Botón Grande de Acción
              Expanded(
                child: isPending 
                ? ElevatedButton.icon(
                    onPressed: () {}, // Aquí iría la lógica del controlador
                    icon: const Icon(Icons.check),
                    label: const Text("Ya tomé"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF018BF0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Color(0xFF0D1F46), size: 18),
                        SizedBox(width: 8),
                        Text("Ya registrado", style: TextStyle(color: Color(0xFF0D1F46), fontWeight: FontWeight.bold)),
                      ],
                    )),
                  ),
              )
            ],
          )
        ],
      ),
    );
  }
}