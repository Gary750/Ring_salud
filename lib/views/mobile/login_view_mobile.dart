import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart'; // Asegúrate de importar tu controlador

class LoginViewMobile extends StatefulWidget {
  const LoginViewMobile({super.key});

  @override
  State<LoginViewMobile> createState() => _LoginViewMobileState();
}

class _LoginViewMobileState extends State<LoginViewMobile> {
  // Instanciamos el controlador
  final AuthController _controller = AuthController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definimos los colores
    final Color primaryBlue = const Color(0xFF0077C2); // Azul botón/logo
    final Color darkBlueText = const Color(0xFF0D1F46); // Azul oscuro texto

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. LOGO ---
                  // Nota: Reemplaza esto con Image.asset('assets/tu_logo.png')
                  const Icon(
                    Icons.local_hospital, 
                    size: 80, 
                    color: Colors.blueAccent
                  ),
                  const SizedBox(height: 10),
                  
                  // --- 2. TÍTULOS ---
                  Text(
                    "RING SALU",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900, // Extra Bold
                      color: darkBlueText,
                      fontFamily: 'Roboto', // O la fuente que uses
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "DR. MARTIN TRIGUEROS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.lightBlue[400],
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  const SizedBox(height: 50),

                  // --- 3. INPUT USUARIO ---
                  _buildLabelSection("Usuario", "Correo o ID"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.userController,
                    decoration: _inputDecoration("paciente@gmail.com"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- 4. INPUT CONTRASEÑA ---
                  _buildLabelSection("Contraseña", "Minimo 8 caracteres"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("************"),
                    validator: (value) {
                      if (value == null || value.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // --- 5. LINK OLVIDASTE CONTRASEÑA ---
                  InkWell(
                    onTap: () {
                      print("Recuperar contraseña");
                    },
                    child: const Text(
                      "Si olvidaste tu contraseña, el administrador de la\nclinica puede ayudarte a restaurarla",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.blue, 
                        fontSize: 12,
                        height: 1.5, // Espaciado entre líneas
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- 6. BOTÓN ACCEDER ---
                  ElevatedButton(
                    onPressed: () => _controller.login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Acceder",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para crear la fila de "Etiqueta ...... Ayuda"
  Widget _buildLabelSection(String label, String helper) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1F46),
            fontSize: 15,
          ),
        ),
        Text(
          helper,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Estilo común para los inputs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}