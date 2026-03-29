import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/emergency_controller.dart';

class EmergencyViewMobile extends StatelessWidget {
  EmergencyViewMobile({super.key});

  final EmergencyController controller = Get.put(EmergencyController());

  @override
  Widget build(BuildContext context) {
    // Colores consistentes con tu diseño
    const Color primaryBlue = Color(0xFF002B7A);
    const Color lightBlueText = Color(0xFF43C7FF);
    const Color emergencyRed = Color(0xFFEF5350);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                'Botón de emergencia',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const SizedBox(height: 10),
              const Text(
                'Al pulsar, se enviará un SMS y se realizará una llamada de alerta a tu contacto de emergencia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: lightBlueText, fontSize: 15, height: 1.3),
              ),
              const SizedBox(height: 25),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), 
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: emergencyRed, size: 18),
                    SizedBox(width: 8),
                    Text('Solo para casos urgentes', style: TextStyle(color: emergencyRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: () => controller.confirmEmergency(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                  decoration: BoxDecoration(
                    color: emergencyRed,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(color: emergencyRed.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.notifications_active_outlined, color: Colors.white, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'Enviar alerta ahora', 
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Presiona y sigue las instrucciones', 
                        style: TextStyle(color: Colors.white70, fontSize: 13)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF34AADC), 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.checklist, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          '¿Qué pasará después?', 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('Verás un mensaje de confirmación en la pantalla.'),
                    _buildStep('El sistema intentará enviar un SMS automático a tu contacto.'),
                    _buildStep('El sistema intentará realizar una llamada a tu contacto.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Obx(() => _buildInfoRow('Última alerta enviada', controller.lastAlertDate.value, lightBlueText)),
              const SizedBox(height: 15),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado actual', style: TextStyle(color: lightBlueText)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5FE), 
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text(
                      controller.alertStatus.value, 
                      style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 30),
              
              TextButton(
                onPressed: () => _showHistory(context),
                child: const Text(
                  'Ver historial de alertas', 
                  style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(value, style: TextStyle(color: color.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    const Color primaryBlue = Color(0xFF002B7A);
    const Color lightBlueText = Color(0xFF43C7FF);

    controller.fetchHistory();
    Get.to(() => Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Fondo sutil
      appBar: AppBar(
        title: const Text("Mi Historial", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.historyList.isEmpty) {
          return const Center(child: Text("Sin historial", style: TextStyle(color: lightBlueText)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.historyList.length,
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emergency_outlined, color: Color(0xFFEF5350)),
                ),
                title: const Text(
                  "Alerta Activada",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Fecha: ${item['fecha_evento']}",
                  style: const TextStyle(color: lightBlueText, fontSize: 13),
                ),
              ),
            );
          },
        );
      }),
    ));
  }
}