import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterController _controller = RegisterController();
  bool _isLoading = false;

  // --- PALETA DE COLORES (Ring Salud) ---
  final Color bgLight = const Color(0xFFF0F4FA);      // Fondo gris azulado
  final Color primaryBlue = const Color(0xFF018BF0);  // Azul Botón
  final Color textDark = const Color(0xFF0D1F46);     // Azul oscuro texto
  final Color inputFill = const Color(0xFFF5F9FF);    // Fondo input

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // --- RESPONSIVIDAD ---
          // Si el ancho es > 900px (PC), usamos diseño dividido.
          // Si es menor, usamos diseño vertical (Móvil).
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // ======================================================
  //              DISEÑO ESCRITORIO (PC)
  // ======================================================
  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Row(
          children: [
            // Izquierda: Texto de Marketing
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(right: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("● Nuevo Usuario", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    Text("Únete a Ring Salud", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 20),
                    Text(
                      "Crea una cuenta para gestionar tus citas médicas o administrar tus pacientes desde una plataforma centralizada.",
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey[600], height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            // Derecha: Tarjeta con Formulario
            Expanded(
              flex: 4,
              child: _buildFormCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //              DISEÑO MÓVIL (Celular)
  // ======================================================
  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.app_registration, size: 50, color: primaryBlue),
            const SizedBox(height: 10),
            Text("Crear Cuenta", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textDark)),
            const SizedBox(height: 30),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildFormCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //          TARJETA DEL FORMULARIO (Reutilizable)
  // ======================================================
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: textDark.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- 1. DROPDOWN (Selector de Rol) ---
            _buildLabel("Soy..."),
            DropdownButtonFormField<String>(
              value: _controller.selectedRole,
              decoration: _inputDecoration("Selecciona tu perfil"),
              items: const [
                DropdownMenuItem(
                  value: 'paciente',
                  child: Row(children: [Icon(Icons.person_outline, color: Colors.grey), SizedBox(width: 10), Text("Paciente")]),
                ),
                DropdownMenuItem(
                  value: 'doctor',
                  child: Row(children: [Icon(Icons.medical_services_outlined, color: Colors.grey), SizedBox(width: 10), Text("Médico / Especialista")]),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _controller.selectedRole = val);
              },
            ),
            const SizedBox(height: 20),

            // --- 2. INPUT EMAIL ---
            _buildLabel("Correo Electrónico"),
            TextFormField(
              controller: _controller.emailController,
              decoration: _inputDecoration("ejemplo@correo.com"),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.contains("@") ? null : "Correo inválido",
            ),
            const SizedBox(height: 20),

            // --- 3. INPUT PASSWORD ---
            _buildLabel("Contraseña"),
            TextFormField(
              controller: _controller.passwordController,
              obscureText: true,
              decoration: _inputDecoration("Mínimo 6 caracteres"),
              validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
            ),
            const SizedBox(height: 30),

            // --- 4. BOTÓN REGISTRAR ---
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                bool exito = await _controller.register(context);
                setState(() => _isLoading = false);
                if (exito && mounted) Navigator.pop(context); // Volver al login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Registrarse", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- ESTILOS VISUALES ---
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey[200]),
      filled: true,
      fillColor: inputFill, // Color #F5F9FF
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}