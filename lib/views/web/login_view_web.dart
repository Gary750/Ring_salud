import 'package:flutter/material.dart';
import 'package:ring_salud/views/shared/register_view.dart';
import '../../controllers/auth_controller.dart';

class LoginViewWeb extends StatefulWidget {
  const LoginViewWeb({super.key});

  @override
  State<LoginViewWeb> createState() => _LoginViewWebState();
}

class _LoginViewWebState extends State<LoginViewWeb> {
  final AuthController _controller = AuthController();
  bool _rememberMe = false; // Estado local para el checkbox visual

  @override
  Widget build(BuildContext context) {
    // Colores extraídos de la imagen
    final Color bgLight = const Color(0xFFF0F4FA); // Fondo general
    final Color primaryBlue = const Color(0xFF018BF0); // Botón principal
    final Color textDark = const Color(0xFF022380); // Títulos oscuros

    return Scaffold(
      backgroundColor: bgLight,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Ancho máximo para monitores grandes
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              // ---------------------------------------------
              // LADO IZQUIERDO: Branding e Info
              // ---------------------------------------------
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip superior
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "● Plataforma de tratamientos",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Título Grande
                      Text(
                        "Acceso para médicos",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Descripción
                      Text(
                        "Gestiona pacientes, tratamientos y alertas desde un panel seguro con entorno clínico en azul.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Caja de Aviso Azul Claro
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5FE), // Azul muy claro
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.lightBlue.shade100),
                        ),
                        child: const Text(
                          "Las credenciales del médico son independientes de las del paciente.\nLos pacientes acceden con número de control y contraseña generados en tu panel.",
                          style: TextStyle(
                            color: Color(0xFF024B80),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------
              // LADO DERECHO: Tarjeta de Login (Card)
              // ---------------------------------------------
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Iniciar sesión",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Introduce tus credenciales de médico para acceder al panel.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 30),

                          // Input Usuario
                          _buildLabel("Usuario"),
                          TextFormField(
                            controller: _controller.userController,
                            decoration: _inputDecoration("correo@hospital.com"),
                            validator: (v) => v!.isEmpty ? "Requerido" : null,
                          ),
                          const SizedBox(height: 20),

                          // Input Contraseña
                          _buildLabel("Contraseña"),
                          TextFormField(
                            controller: _controller.passwordController,
                            obscureText: true,
                            decoration: _inputDecoration("••••••••"),
                            validator: (v) =>
                                v!.length < 6 ? "Mínimo 6 caracteres" : null,
                          ),

                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterView()
                                )
                              );
                            },
                            child: Text(
                              "Registrar nuevo especialista",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // Fila: Checkbox y Olvidaste contraseña
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v!),
                                    activeColor: primaryBlue,
                                  ),
                                  Text(
                                    "Recordar sesión",
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "¿Olvidaste tu contraseña?",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Botón ACCEDER (Principal)
                          ElevatedButton(
                            onPressed: () => _controller.login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Acceder",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 15),
                          /*
                          // Botón PACIENTES (Outline)
                          OutlinedButton(
                            onPressed: () {
                              // Aquí podrías redirigir a una página de descarga de la app móvil
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryBlue,
                              side: BorderSide(color: primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Acceso para pacientes"),
                          ),
*/
                          const SizedBox(height: 20),
                          /*
                          // Error Message Placeholder (Visual)
                          const Text(
                            "Credenciales incorrectas. Revisa tu usuario y contraseña.",
                            style: TextStyle(color: Colors.redAccent, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          */
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares para limpiar el código ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF018BF0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey[200]),
      filled: true,
      fillColor: const Color(
        0xFFF5F9FF,
      ), // Fondo azul muy pálido dentro del input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // Sin borde por defecto (estilo moderno)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF018BF0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
