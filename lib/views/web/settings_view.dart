import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  Map<String, dynamic>? _doctorData;

  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Switches de preferencias (Simulados por ahora)
  bool _soundAlerts = true;
  bool _browserNotifications = true;
  bool _emailWeeklySummary = false;

  // Colores del diseño
  final _textDark = const Color(0xFF0D1F46);
  final _primaryBlue = const Color(0xFF018BF0);

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    setState(() => _isLoading = true);
    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail != null) {
        final data = await supabase.from('medico').select().eq('correo', userEmail).single();
        _doctorData = data;
        _nameController.text = data['usuario'] ?? '';
        _emailController.text = data['correo'] ?? '';
      }
    } catch (e) {
      debugPrint("Error cargando perfil: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _cerrarSesion() async {
    await supabase.auth.signOut();
    // Gracias a nuestro AuthGate en main.dart, esto te mandará directo al Login.
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
          
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Izquierda
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildAlertSettingsCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Columna Derecha
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _buildSecurityCard(),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Configuración de la cuenta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark)),
        const SizedBox(height: 5),
        const Text("Gestiona tu perfil profesional, preferencias de notificaciones y seguridad.", style: TextStyle(color: Colors.blue, fontSize: 13)),
        const SizedBox(height: 10),
        const Text("Módulos · Configuración", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildProfileCard() {
    return _buildCardWrapper(
      title: "Perfil del Médico",
      subtitle: "Información visible en los reportes y gestión interna.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, size: 30, color: _primaryBlue)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nombre del Médico", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration("Ej. Dr. Juan Pérez"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Correo de contacto", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            readOnly: true, // El correo de auth no se cambia tan fácil
            decoration: _inputDecoration("correo@hospital.com").copyWith(
              fillColor: Colors.grey.shade100,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white),
              child: const Text("Guardar cambios"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlertSettingsCard() {
    return _buildCardWrapper(
      title: "Preferencias de Alertas",
      subtitle: "Personaliza cómo recibes los avisos de emergencias e incumplimientos.",
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Sonido de alarma (SOS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("Reproducir un sonido fuerte cuando un paciente presione el botón de emergencia.", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            value: _soundAlerts,
            activeColor: _primaryBlue,
            onChanged: (bool value) => setState(() => _soundAlerts = value),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Notificaciones del navegador", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("Mostrar un banner flotante en tu computadora si la pestaña está en segundo plano.", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            value: _browserNotifications,
            activeColor: _primaryBlue,
            onChanged: (bool value) => setState(() => _browserNotifications = value),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Resumen semanal por correo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("Recibir un reporte en PDF con la adherencia global de tus pacientes.", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            value: _emailWeeklySummary,
            activeColor: _primaryBlue,
            onChanged: (bool value) => setState(() => _emailWeeklySummary = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return _buildCardWrapper(
      title: "Sesión y Seguridad",
      subtitle: "Control de acceso a tu panel médico.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Lógica de cambio de contraseña
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text("Cambiar contraseña"),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 15),
          const Text("Último acceso: Hoy, desde este navegador.", style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
          const Divider(height: 40),
          
          ElevatedButton.icon(
            onPressed: () async {
              // Confirmación antes de salir
              final bool confirmar = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("¿Cerrar sesión?"),
                  content: const Text("Dejarás de recibir notificaciones en tiempo real en este navegador."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true), 
                      child: const Text("Sí, cerrar sesión", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ) ?? false;

              if (confirmar) {
                _cerrarSesion();
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar Sesión"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16)
            ),
          ),
        ],
      ),
    );
  }

  // Helper visual para las tarjetas
  Widget _buildCardWrapper({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          Text(subtitle, style: const TextStyle(color: Colors.blue, fontSize: 12)),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}