import 'package:flutter/material.dart';

class AuthController {
  // Controladores para los campos de texto
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Llave para validar el formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Simulación de la lógica de login
  void login(BuildContext context) {
    if (formKey.currentState!.validate()) {
      print("Login con: ${userController.text} y ${passwordController.text}");

    }
  }

  // Limpieza de memoria
  void dispose() {
    userController.dispose();
    passwordController.dispose();
  }
}