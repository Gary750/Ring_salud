import 'package:flutter/material.dart';
import '../../controllers/history_controller.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final HistoryController _controller = HistoryController();
  
  // Datos reales
  List<Map<String, dynamic>> _allRecords = [];
  bool _isLoading = true;

  // Estados visuales para los filtros
  String filtroEvento = 'Todos';
  String filtroOrigen = 'App paciente';
  String filtroTiempo = 'Últimos 7 días';

  // Métricas calculadas
  int confirmadas = 0;
  int noConfirmadas = 0;
  int enviados = 0;
  double adherencia = 0.0;
  int pacientesActivos = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar datos al entrar
  }

  // Función para cargar datos de la BD según el filtro de tiempo
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    int days = 7;
    if (filtroTiempo == 'Hoy') days = 0;
    if (filtroTiempo == 'Últimos 30 días') days = 30;

    final records = await _controller.fetchGlobalHistory(days);
    
    _allRecords = records;
    _calcularMetricas(); // Procesar las matemáticas
    
    setState(() => _isLoading = false);
  }

  // Motor matemático para las KPIs
  void _calcularMetricas() {
    confirmadas = 0;
    noConfirmadas = 0;
    enviados = 0;
    Set<String> pacientesUnicos = {};

    for (var r in _allRecords) {
      bool isConf = r['confirmado'] ?? false;
      bool isEnv = r['enviado'] ?? false;
      DateTime fechaProg = DateTime.parse(r['fecha_hora_programada']);

      if (isEnv) enviados++;

      if (isConf) {
        confirmadas++;
      } else if (fechaProg.add(const Duration(hours: 1)).isBefore(DateTime.now())) {
        noConfirmadas++; // Si pasó más de 1 hora y no confirmó, es omisión
      }

      // Extraer datos anidados de forma segura
      final tratamiento = r['tratamientos'] ?? {};
      final paciente = tratamiento['paciente'] ?? {};
      final String usuarioId = paciente['usuario'] ?? '0';
      pacientesUnicos.add(usuarioId);
    }

    pacientesActivos = pacientesUnicos.length;
    int totalTomas = confirmadas + noConfirmadas;
    adherencia = totalTomas > 0 ? (confirmadas / totalTomas) * 100 : 0.0;
  }

  // Lógica de filtrado local para los botones ("Toma confirmada", etc.)
  List<Map<String, dynamic>> get _registrosFiltrados {
    if (filtroEvento == 'Todos') return _allRecords;
    
    return _allRecords.where((r) {
      bool isConf = r['confirmado'] ?? false;
      bool isEnv = r['enviado'] ?? false;
      DateTime fechaProg = DateTime.parse(r['fecha_hora_programada']);
      
      if (filtroEvento == 'Toma confirmada') return isConf;
      if (filtroEvento == 'No confirmada') return !isConf && fechaProg.add(const Duration(hours: 1)).isBefore(DateTime.now());
      if (filtroEvento == 'Recordatorio enviado') return isEnv && !isConf;
      
      return true;
    }).toList();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildResumenCard()),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: _buildFiltrosCard()),
            ],
          ),
          const SizedBox(height: 20),
          _buildTablaHistorial(),
        ],
      ),
    );
  }

  // ==============================================================
  // WIDGETS
  // ==============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Historial de confirmaciones", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1F46))),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(20)),
              child: const Text("Registro completo", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text("Visualiza de forma ordenada todas las tomas registradas por tus pacientes.", style: TextStyle(color: Colors.blue, fontSize: 13)),
      ],
    );
  }

  Widget _buildResumenCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Resumen del periodo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(filtroTiempo, style: const TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMetricBox("Tomas confirmadas", confirmadas.toString(), "Confirmadas por app")),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricBox("Tomas no confirmadas", noConfirmadas.toString(), "Incluye omisiones")),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricBox("Recordatorios enviados", enviados.toString(), "SMS - App")),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoDato("Cumplimiento de tratamiento estimada", "${adherencia.toStringAsFixed(0)}%"),
              const Text("Meta: > 90%", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoDato("Pacientes con seguimiento activo", pacientesActivos.toString()),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String titulo, String valor, String subtitulo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF018BF0), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitulo, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFiltrosCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filtros del historial", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Tipo:", style: TextStyle(color: Colors.blue, fontSize: 12))),
              Expanded(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _buildPill("Todos", filtroEvento == 'Todos', (v) => setState(() => filtroEvento = v)),
                    _buildPill("Toma confirmada", filtroEvento == 'Toma confirmada', (v) => setState(() => filtroEvento = v)),
                    _buildPill("No confirmada", filtroEvento == 'No confirmada', (v) => setState(() => filtroEvento = v)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Rango:", style: TextStyle(color: Colors.blue, fontSize: 12))),
              Expanded(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _buildPill("Hoy", filtroTiempo == 'Hoy', (v) { filtroTiempo = v; _loadData(); }),
                    _buildPill("Últimos 7 días", filtroTiempo == 'Últimos 7 días', (v) { filtroTiempo = v; _loadData(); }),
                    _buildPill("Últimos 30 días", filtroTiempo == 'Últimos 30 días', (v) { filtroTiempo = v; _loadData(); }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF018BF0) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF018BF0) : Colors.grey.shade300)
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11)),
      ),
    );
  }

  Widget _buildInfoDato(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ==============================================================
  // TABLA DE HISTORIAL CON DATOS REALES
  // ==============================================================
  Widget _buildTablaHistorial() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Historial cronológico", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          const Row(
            children: [
              Expanded(flex: 2, child: Text("Fecha y hora", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Paciente", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Medicamento", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Estado", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),
          
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_registrosFiltrados.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No hay registros que coincidan con los filtros.")))
          else
            ..._registrosFiltrados.map((record) => _buildFilaReal(record)),
        ],
      ),
    );
  }

  Widget _buildFilaReal(Map<String, dynamic> record) {
    final t = record['tratamientos'] ?? {};
    final p = t['paciente'] ?? {};
    
    DateTime date = DateTime.parse(record['fecha_hora_programada']).toLocal();
    String fecha = "${date.day}/${date.month} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    
    String pacienteTxt = "${p['nombre']} · ${p['usuario']}";
    String medTxt = "${t['nombre_medicamento']} ${t['dosis']}";

    bool isConf = record['confirmado'] ?? false;
    final List confirmaciones = record['historial_confirmaciones'] ?? [];
    
    String estado = isConf ? 'Toma confirmada' : 'Pendiente';
    Color badgeColor = Colors.grey;

    if (isConf) {
      if (confirmaciones.isNotEmpty && (confirmaciones.first['estado'] ?? '').toLowerCase().contains('retraso')) {
        estado = 'Toma con retraso';
        badgeColor = Colors.orange;
      } else {
        badgeColor = Colors.green; // A tiempo
      }
    } else {
      if (date.add(const Duration(hours: 1)).isBefore(DateTime.now())) {
        estado = 'No confirmada';
        badgeColor = Colors.redAccent;
      } else if (record['enviado'] == true) {
        estado = 'Recordatorio enviado';
        badgeColor = Colors.orangeAccent;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(fecha, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(pacienteTxt, style: const TextStyle(color: Colors.blueGrey))),
          Expanded(flex: 3, child: Text(medTxt, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
              child: Text(estado, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
      ),
    );
  }
}