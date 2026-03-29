import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:developer';
import '../../models/medication_model.dart';
import '../../controllers/patient_mobile_controller.dart';
import '../../services/notification_service.dart';
import 'emergency_view_mobile.dart';
import 'recordatorios_mobile.dart';
import 'profile_view.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final supabase = Supabase.instance.client;

  List<MedicationTask> tasks = [];
  int _currentIndex = 0;
  bool isLoading = true;
  Timer? _refreshTimer;

  final darkBlueText = const Color(0xFF002A5C);
  final lightBlueText = const Color(0xFF56CCF2);
  final primaryBlue = const Color(0xFF018BF0);
  final errorRed = const Color(0xFFE53935);
  final bgColor = const Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();

    NotificationService.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cargarMedicamentos();
    });

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _ordenarTareas(List<MedicationTask> lista) {
    lista.sort((a, b) {
      if (a.status == "confirmado" && b.status != "confirmado") return 1;
      if (a.status != "confirmado" && b.status == "confirmado") return -1;
      return a.time.compareTo(b.time);
    });
  }

  String _obtenerEstadoTiempo(String horaTomaStr) {
    try {
      final ahora = DateTime.now();
      final partes = horaTomaStr.split(':');
      final horaToma = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
        int.parse(partes[0]),
        int.parse(partes[1]),
      );
      final diferenciaMinutos = ahora.difference(horaToma).inMinutes;

      if (diferenciaMinutos > 30) return "tarde";
      if (diferenciaMinutos >= -2) return "habilitado";
      return "bloqueado";
    } catch (_) {
      return "bloqueado";
    }
  }

Future<void> cargarMedicamentos() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await NotificationService.cancelarTodasLasAlarmas();

    try {
      // 1. OBTENER ID DEL PACIENTE SEGURO (Directo, sin usar Provider)
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw "No hay sesión activa";

      final userResponse = await supabase
          .from('paciente')
          .select('id_paciente')
          .eq('correo', userEmail)
          .maybeSingle();

      if (userResponse == null) {
        if (mounted) setState(() { tasks = []; isLoading = false; });
        return;
      }

      final int idPacienteLogueado = userResponse['id_paciente'];

      // Rango de horas para HOY
      final hoy = DateTime.now();
      final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final finDia = inicioDia.add(const Duration(days: 1));

      // 2. OBTENER TRATAMIENTOS (Consulta 1 de 2)
      final tratamientosData = await supabase
          .from('tratamientos')
          .select('id_tratamiento, nombre_medicamento, dosis, fecha_inicio, fecha_fin')
          .eq('id_paciente', idPacienteLogueado);

      if (tratamientosData.isEmpty) {
        if (mounted) setState(() { tasks = []; isLoading = false; });
        return;
      }

      // Creamos un "diccionario" para conectar rápido el tratamiento con el recordatorio
      final Map<int, dynamic> mapTratamientos = {
        for (var t in tratamientosData) t['id_tratamiento']: t
      };
      final idsTratamientos = mapTratamientos.keys.toList();

      // 3. OBTENER RECORDATORIOS DE HOY (Consulta 2 de 2)
      final data = await supabase
          .from('recordatorios_medicacion')
          .select('id_recordatorio, fecha_hora_programada, confirmado, id_tratamiento')
          .inFilter('id_tratamiento', idsTratamientos) // Usamos la lista de IDs seguros
          .gte('fecha_hora_programada', inicioDia.toIso8601String())
          .lt('fecha_hora_programada', finDia.toIso8601String())
          .order('fecha_hora_programada', ascending: true);

      List<MedicationTask> loadedTasks = [];

      for (var item in data) {
        final tratamiento = mapTratamientos[item['id_tratamiento']];
        if (tratamiento == null) continue;

        // Convertimos a hora local por si Supabase lo manda en formato UTC
        final DateTime fechaProgramada = DateTime.parse(item['fecha_hora_programada']).toLocal();

        final task = MedicationTask(
          idRecordatorio: item['id_recordatorio'],
          time: fechaProgramada.toString().substring(11, 16), // Extraemos el formato "HH:mm"
          name: tratamiento['nombre_medicamento'] ?? "Medicamento",
          dose: tratamiento['dosis'] ?? "",
          frequency: calcularFrecuencia(
            tratamiento['fecha_inicio']?.toString(),
            tratamiento['fecha_fin']?.toString(),
          ),
          status: item['confirmado'] == true ? "confirmado" : "pendiente",
        );

        loadedTasks.add(task);

        if (task.status != "confirmado" && fechaProgramada.isAfter(DateTime.now())) {
          await NotificationService.programarAlarma(
            task.idRecordatorio,
            task.name,
            fechaProgramada,
          );
        }
      }

      _ordenarTareas(loadedTasks);

      if (mounted) {
        setState(() {
          tasks = loadedTasks;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error al cargar medicamentos: $e"); // Ahora sí imprimirá en consola si algo falla
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _confirmarTomaTardia(MedicationTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Toma con retraso", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Estás registrando la toma de ${task.name} fuera del horario ideal. ¿Deseas continuar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: errorRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              confirmarToma(task, estadoEspecial: 'confirmado_tarde');
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  Future<void> confirmarToma(MedicationTask task, {String estadoEspecial = 'confirmado'}) async {
    final now = DateTime.now();
    try {
      await supabase.from('recordatorios_medicacion').update({'confirmado': true}).eq('id_recordatorio', task.idRecordatorio);

      await supabase.from('historial_confirmaciones').insert({
        'id_recordatorio': task.idRecordatorio,
        'fecha_confirmacion': now.toIso8601String(),
        'estado': estadoEspecial
      });

      await NotificationService.cancelarAlarma(task.idRecordatorio);

      if (mounted) {
        setState(() {
          task.status = "confirmado";
          _ordenarTareas(tasks); 
        });
      }
    } catch (e) {
      log("Error al confirmar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      EmergencyViewMobile(),
      const RecordatoriosMobile(),
      const ProfileView()
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: primaryBlue,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication, color: Colors.white), label: "Inicio"),
          NavigationDestination(icon: Icon(Icons.emergency_outlined), selectedIcon: Icon(Icons.emergency, color: Colors.white), label: "Emergencia"),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications, color: Colors.white), label: "Recordatorios"),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Colors.white), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    int confirmadas = tasks.where((t) => t.status == "confirmado").length;
    int pendientes = tasks.length - confirmadas;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tomas de hoy", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkBlueText)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: lightBlueText, borderRadius: BorderRadius.circular(20)),
                    child: Text("Hoy · ${_obtenerDiaSemana()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildSummaryBox(Icons.list_alt, "Total", "${tasks.length}", primaryBlue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryBox(Icons.pending_actions, "Pendientes", "$pendientes", Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryBox(Icons.check_circle, "Listas", "$confirmadas", const Color(0xFF4CAF50))),
                ],
              ),
              const SizedBox(height: 20),
              Text("Sigue esta lista. El botón se habilitará 2 min antes.", style: TextStyle(color: lightBlueText, fontSize: 15)),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty ? _emptyStateBonito() : RefreshIndicator(
            onRefresh: cargarMedicamentos,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: tasks.length,
              itemBuilder: (_, i) => _buildMedicationCard(tasks[i]),
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildSummaryBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkBlueText)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.time, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlueText)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                    Text(task.dose, style: TextStyle(color: lightBlueText, fontSize: 14)),
                  ],
                ),
              ),
              _buildStatusBadge(task),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: _buildActionButton(task)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MedicationTask task) {
    String tiempo = _obtenerEstadoTiempo(task.time);
    if (task.status == "confirmado") return _badge(const Color(0xFF4FC3F7), Colors.white, Icons.check_circle, "Confirmado");
    if (tiempo == "tarde") return _badge(errorRed.withOpacity(0.1), errorRed, Icons.history, "Tarde");
    return _badge(Colors.orange.withOpacity(0.1), Colors.orange, Icons.access_time, "Pendiente");
  }

  Widget _badge(Color bg, Color txt, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: txt), const SizedBox(width: 4), Text(label, style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildActionButton(MedicationTask task) {
    bool isConfirmado = task.status == "confirmado";
    String tiempo = _obtenerEstadoTiempo(task.time);
    Color btnColor = primaryBlue;
    String btnText = "Ya tomé";
    IconData icon = Icons.check;

    if (isConfirmado) {
      btnColor = const Color(0xFFE1F5FE);
      btnText = "Ya registrado";
    } else if (tiempo == "tarde") {
      btnColor = errorRed;
      btnText = "Demasiado tarde";
      icon = Icons.warning_amber_rounded;
    } else if (tiempo == "bloqueado") {
      btnColor = Colors.grey.shade300;
      btnText = "Bloqueado";
      icon = Icons.lock_clock;
    }

    return ElevatedButton(
      onPressed: (isConfirmado || tiempo == "bloqueado") 
          ? null 
          : () => (tiempo == "tarde") ? _confirmarTomaTardia(task) : confirmarToma(task),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        disabledBackgroundColor: isConfirmado ? const Color(0xFFE1F5FE) : Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: isConfirmado ? lightBlueText : Colors.white),
          const SizedBox(width: 8),
          Text(btnText, style: TextStyle(color: isConfirmado ? lightBlueText : Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(Colors.orange, "Pendiente"),
          const SizedBox(width: 15),
          _dot(lightBlueText, "Confirmado"),
          const SizedBox(width: 15),
          _dot(errorRed, "Tarde"),
        ],
      ),
    );
  }

  Widget _dot(Color c, String t) {
    return Row(children: [CircleAvatar(radius: 4, backgroundColor: c), const SizedBox(width: 6), Text(t, style: TextStyle(color: lightBlueText, fontSize: 12))]);
  }

  Widget _emptyStateBonito() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.check_circle_outline, size: 80, color: lightBlueText.withOpacity(0.5)),
      const SizedBox(height: 20),
      Text("Todo al día 🎉", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlueText)),
    ]));
  }

  String calcularFrecuencia(String? inicio, String? fin) {
    if (inicio == null || fin == null) return "Frecuencia fija";
    try {
      final i = DateTime.parse(inicio);
      final f = DateTime.parse(fin);
      return "Por ${f.difference(i).inDays} días";
    } catch (_) { return "Frecuencia fija"; }
  }

  String _obtenerDiaSemana() {
    return ["", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][DateTime.now().weekday];
  }
}