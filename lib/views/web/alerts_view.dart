import 'package:flutter/material.dart';
import '../../controllers/alerts_controller.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({super.key});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  final AlertsController _controller = AlertsController();
  
  // Datos
  List<Map<String, dynamic>> _todasLasAlertas = [];
  int _totalPacientes = 0;
  bool _isLoading = true;

  // Estados visuales de filtros
  String filtroEstado = 'Todos';
  String filtroPeriodo = 'Últimos 7 días';

  // Métricas
  int criticos = 0;
  int retrasos = 0;
  int pacientesSinAlertas = 0;

  // Colores del diseño
  final textDark = const Color(0xFF0D1F46);
  final primaryBlue = const Color(0xFF018BF0);
  final redAlert = const Color(0xFFE53935);
  final orangeAlert = const Color(0xFFFB8C00);
  final cyanAlert = const Color(0xFF00ACC1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    int days = 7;
    if (filtroPeriodo == 'Hoy') days = 0;
    if (filtroPeriodo == 'Últimos 30 días') days = 30;

    final data = await _controller.fetchAlertsData(days);
    final rawRecords = data['records'] as List<Map<String, dynamic>>;
    _totalPacientes = data['totalPacientes'];
    
    _procesarAlertas(rawRecords);
    
    setState(() => _isLoading = false);
  }

  // Motor lógico para clasificar si una toma normal se vuelve "Alerta"
  void _procesarAlertas(List<Map<String, dynamic>> rawRecords) {
    _todasLasAlertas.clear();
    criticos = 0;
    retrasos = 0;
    Set<int> pacientesConAlerta = {};
    final now = DateTime.now();

    for (var r in rawRecords) {
      final isConf = r['confirmado'] ?? false;
      final fechaProg = DateTime.parse(r['fecha_hora_programada']).toLocal();
      final diffMinutos = now.difference(fechaProg).inMinutes;
      final List confirmaciones = r['historial_confirmaciones'] ?? [];
      
      String estadoAlerta = "";
      String tiempoRetraso = "";

      if (!isConf) {
        if (diffMinutos >= 120) {
          estadoAlerta = "Incumplimiento crítico";
          tiempoRetraso = "+${diffMinutos ~/ 60} h ${diffMinutos % 60} min";
          criticos++;
        } else if (diffMinutos >= 30) {
          estadoAlerta = "Retraso moderado";
          tiempoRetraso = "+$diffMinutos min";
          retrasos++;
        }
      } else {
        // Si confirmó, revisamos si lo hizo tarde
        if (confirmaciones.isNotEmpty && (confirmaciones.first['estado'] ?? '').toLowerCase().contains('retraso')) {
          estadoAlerta = "Confirmado tras recordatorio";
          tiempoRetraso = "Resuelto";
        }
      }

      // Si clasificó como algún tipo de alerta, lo agregamos a la lista
      if (estadoAlerta.isNotEmpty) {
        final pacienteId = r['tratamientos']['paciente']['id_paciente'];
        pacientesConAlerta.add(pacienteId);

        _todasLasAlertas.add({
          'paciente': r['tratamientos']['paciente'],
          'medicamento': r['tratamientos']['nombre_medicamento'],
          'fecha_prog': fechaProg,
          'estado_alerta': estadoAlerta,
          'tiempo_retraso': tiempoRetraso,
        });
      }
    }

    pacientesSinAlertas = _totalPacientes - pacientesConAlerta.length;
    if (pacientesSinAlertas < 0) pacientesSinAlertas = 0;
  }

  List<Map<String, dynamic>> get _alertasFiltradas {
    if (filtroEstado == 'Todos') return _todasLasAlertas;
    return _todasLasAlertas.where((a) {
      final est = a['estado_alerta'];
      if (filtroEstado == 'Crítico') return est == 'Incumplimiento crítico';
      if (filtroEstado == 'Retraso') return est == 'Retraso moderado';
      if (filtroEstado == 'Resuelto hoy') return est == 'Confirmado tras recordatorio';
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
          _buildTablaAlertas(),
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
            Text("Alertas e incumplimientos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
              child: const Text("Monitorizando en tiempo real", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar paciente por nombre...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: _loadData, 
              icon: const Icon(Icons.refresh, size: 18), 
              label: const Text("Actualizar lista"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue, elevation: 0, side: const BorderSide(color: Colors.blueGrey, width: 0.5)),
            )
          ],
        ),
        const SizedBox(height: 5),
        const Text("Revisa qué pacientes no han confirmado sus tomas a tiempo y prioriza tu seguimiento.", style: TextStyle(color: Colors.blue, fontSize: 13)),
        const SizedBox(height: 10),
        const Text("Módulos · Alertas", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildResumenCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Estado general", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
              Text(filtroPeriodo, style: const TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
          const Text("Resumen rápido de tomas no confirmadas y retrasos recientes.", style: TextStyle(color: Colors.blue, fontSize: 12)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: _buildMetricBox("Incumplimientos críticos", criticos.toString(), "Sin confirmación tras 2 recordatorios", const Color(0xFF2C82C9))),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricBox("Retrasos moderados", retrasos.toString(), "Confirmados con más de 30 min de retraso", const Color(0xFF1E8BC3))),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricBox("Pacientes sin alertas", pacientesSinAlertas.toString(), "Sin incidentes en la última semana", const Color(0xFF3498DB))),
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap( 
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              const Text("Leyenda:  ", style: TextStyle(color: Colors.blue, fontSize: 11)),
              _buildDot(redAlert), const Text(" Incumplimiento crítico   ", style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
              _buildDot(orangeAlert), const Text(" Retraso moderado   ", style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
              _buildDot(primaryBlue), const Text(" Tomas al día", style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
            ],
          ),
          const Divider(height: 30),
          const Text("Las alertas se generan cuando el paciente no confirma una toma dentro del margen definido. Los recordatorios por SMS/WhatsApp se registran automáticamente en el historial.", style: TextStyle(color: Colors.blue, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String titulo, String valor, String subtitulo, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
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

  Widget _buildDot(Color c) => Container(margin: const EdgeInsets.only(right: 4), width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _buildFiltrosCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Filtros rápidos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
          const Text("Refina la lista de pacientes con alertas abiertas.", style: TextStyle(color: Colors.blue, fontSize: 12)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Estado:", style: TextStyle(color: Colors.blue, fontSize: 12))),
              _buildPill("Todos", filtroEstado == 'Todos', (v) => setState(() => filtroEstado = v)),
              const SizedBox(width: 10), _buildDot(redAlert), _buildPillText("Crítico", filtroEstado == 'Crítico', (v) => setState(() => filtroEstado = v)),
              const SizedBox(width: 10), _buildDot(orangeAlert), _buildPillText("Retraso", filtroEstado == 'Retraso', (v) => setState(() => filtroEstado = v)),
              const SizedBox(width: 10), _buildDot(cyanAlert), _buildPillText("Resuelto hoy", filtroEstado == 'Resuelto hoy', (v) => setState(() => filtroEstado = v)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Periodo:", style: TextStyle(color: Colors.blue, fontSize: 12))),
              Wrap(
                spacing: 8,
                children: [
                  _buildPill("Hoy", filtroPeriodo == 'Hoy', (v) { filtroPeriodo = v; _loadData(); }),
                  _buildPill("Últimos 7 días", filtroPeriodo == 'Últimos 7 días', (v) { filtroPeriodo = v; _loadData(); }),
                  _buildPill("Últimos 30 días", filtroPeriodo == 'Últimos 30 días', (v) { filtroPeriodo = v; _loadData(); }),
                ],
              )
            ],
          ),
          SizedBox(height: 30),
          const Text("Consejo: revisa primero los incumplimientos críticos, donde no hubo confirmación ni respuesta a recordatorios.", style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : textDark, fontSize: 11)),
      ),
    );
  }

  Widget _buildPillText(String text, bool isSelected, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(text),
      child: Text(text, style: TextStyle(color: isSelected ? primaryBlue : textDark, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  // ==============================================================
  // TABLA DE ALERTAS
  // ==============================================================
  Widget _buildTablaAlertas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Lista de pacientes con alertas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
              OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.filter_alt_outlined, size: 16), label: const Text("Más filtros"))
            ],
          ),
          const Text("Incluye retrasos y tomas no confirmadas según el margen configurado.", style: TextStyle(color: Colors.blue, fontSize: 12)),
          const Divider(height: 30),
          const Row(
            children: [
              Expanded(flex: 3, child: Text("Paciente", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 3, child: Text("Último evento", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text("Retraso", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text("Estado", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text("Acciones", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const Divider(),
          
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_alertasFiltradas.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No hay alertas activas en este momento. ¡Excelente trabajo!", style: TextStyle(color: Colors.green))))
          else
            ..._alertasFiltradas.map((a) => _buildFilaAlerta(a)),
            
          const Divider(),
          const Text("La app del paciente solo muestra un mensaje simple de recordatorio. Toda la clasificación de incumplimientos y tiempos de retraso se gestiona desde este panel médico.", style: TextStyle(color: Colors.blue, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilaAlerta(Map<String, dynamic> alerta) {
    final paciente = alerta['paciente'];
    final fecha = alerta['fecha_prog'] as DateTime;
    final estadoStr = alerta['estado_alerta'] as String;
    
    String momentoDia = fecha.hour < 12 ? "mañana" : (fecha.hour < 19 ? "mediodía" : "noche");
    String eventoTxt = "${alerta['medicamento']} ($momentoDia)";
    
    Color badgeColor = cyanAlert;
    if (estadoStr == "Incumplimiento crítico") badgeColor = redAlert;
    if (estadoStr == "Retraso moderado") badgeColor = orangeAlert;

    // Determinar acción sugerida visualmente
    String accionBtnTxt = "SMS";
    if (estadoStr == "Incumplimiento crítico") accionBtnTxt = "SMS + WhatsApp";
    if (estadoStr == "Retraso moderado") accionBtnTxt = "App + SMS";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("${paciente['nombre']} · ${paciente['usuario']}", style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 13))),
          Expanded(flex: 3, child: Text(eventoTxt, style: TextStyle(color: textDark, fontSize: 13))),
          Expanded(flex: 2, child: Text(alerta['tiempo_retraso'], style: TextStyle(color: badgeColor, fontSize: 13, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
              child: Text(estadoStr, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )),
          Expanded(flex: 2, child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Text(accionBtnTxt, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text("Ver detalle", style: TextStyle(color: primaryBlue, fontSize: 11, decoration: TextDecoration.underline)),
            ],
          )),
        ],
      ),
    );
  }
}