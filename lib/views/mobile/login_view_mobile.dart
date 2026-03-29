import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class LoginViewMobile extends StatefulWidget {
  const LoginViewMobile({super.key});

  @override
  State<LoginViewMobile> createState() => _LoginViewMobileState();
}

class _LoginViewMobileState extends State<LoginViewMobile> {
  final AuthController _controller = AuthController();

  // 👁️ CONTROL DEL OJO Y CARGA
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF0077C2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                  ),

                  _buildLabelSection("Usuario", "Correo o ID"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.userController,
                    decoration: _inputDecoration("paciente@gmail.com"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildLabelSection("Contraseña", "Minimo 8 caracteres"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller.passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration("************").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _obscurePassword
                              ? Colors.grey
                              : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  InkWell(
                    onTap: () {
                      print("Recuperar contraseña");
                    },
                    child: const Text(
                      "Si olvidaste tu contraseña, el administrador de la\nclinica puede ayudarte a restaurarla",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isLoading 
                      ? null 
                      : () async {
                        setState(() => _isLoading = true);
                        
                        await _controller.login(context);
                        
                        if (mounted) setState(() => _isLoading = false);
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "Acceder",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
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