import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/recordatorios_controller.dart';
import '../../controllers/patient_mobile_controller.dart';

class RecordatoriosMobile extends StatelessWidget {
  const RecordatoriosMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final patientController = Provider.of<PatientController>(context, listen: false);
    final int? idPaciente = patientController.patient?.idPaciente;

    return ChangeNotifierProvider(
      create: (_) => RecordatoriosController()..cargarRecordatorios(idPaciente: idPaciente),
      child: const _RecordatoriosView(),
    );
  }
}

class _RecordatoriosView extends StatelessWidget {
  const _RecordatoriosView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecordatoriosController>();
    final pController = Provider.of<PatientController>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Recordatorios", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2C67))),
            const SizedBox(height: 8),
            Text(
              "${controller.totalEnviados} enviados · ${controller.totalConfirmados} confirmados",
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
            const SizedBox(height: 15),
            
            /// FILTROS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                _filtro(context, "Solo hoy", 1),
                const SizedBox(width: 8),
                _filtro(context, "Últimos 7 días", 2),
                _filtro(context, "Todos", 0),
                const SizedBox(width: 8),
              ],
            ),
            
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: controller.cargando
                    ? const Center(child: CircularProgressIndicator())
                    : controller.mensajeError != null
                        ? _buildError(controller, pController.patient?.idPaciente)
                        : ListView.builder(
                            itemCount: controller.recordatoriosFiltrados.length,
                            itemBuilder: (context, index) {
                              final recordatorio = controller.recordatoriosFiltrados[index];
                              
                              bool mostrarEncabezado = false;
                              if (index == 0) {
                                mostrarEncabezado = true;
                              } else {
                                final fechaActual = recordatorio["fecha"] as DateTime;
                                final fechaAnterior = controller.recordatoriosFiltrados[index - 1]["fecha"] as DateTime;
                                if (fechaActual.day != fechaAnterior.day || 
                                    fechaActual.month != fechaAnterior.month || 
                                    fechaActual.year != fechaAnterior.year) {
                                  mostrarEncabezado = true;
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (mostrarEncabezado)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                                      child: Text(
                                        controller.formatearFecha(recordatorio["fecha"]),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                                      ),
                                    ),
                                  _itemRecordatorio(recordatorio),
                                ],
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(RecordatoriosController controller, int? id) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(controller.mensajeError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => controller.cargarRecordatorios(idPaciente: id), child: const Text("Reintentar"))
      ],
    );
  }

  Widget _filtro(BuildContext context, String texto, int index) {
    final controller = context.watch<RecordatoriosController>();
    final activo = controller.filtroSeleccionado == index;
    return GestureDetector(
      onTap: () => controller.cambiarFiltro(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(texto, style: TextStyle(color: activo ? Colors.white : Colors.blue, fontSize: 12)),
      ),
    );
  }

  Widget _itemRecordatorio(Map<String, dynamic> r) {
    Color colorEstado = r["estado"] == "Visto" ? Colors.teal : (r["estado"] == "Enviado" ? Colors.blueGrey : Colors.orange);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(r["hora"], style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r["titulo"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(r["descripcion"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(r["estado"], style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}