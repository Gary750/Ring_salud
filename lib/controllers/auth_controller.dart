import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //! Supabase
import 'package:flutter/foundation.dart' show kIsWeb; //! Necesario para detectar la plataforma

class AuthController {
  final TextEditingController userController = TextEditingController();   //* Controladores para los campos de texto
  final TextEditingController passwordController = TextEditingController(); //* Controladores para los campos de texto
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();  //* Llave para validar el formulario
  final supabase = Supabase.instance.client;  //* Cliente de Supabase

  Future <void> login(BuildContext context) async{
    if (!formKey.currentState!.validate()) {
      return; //! Si el formulario no es válido, salir de la función
    }

    try{
      //? 1. Intentar iniciar sesión con Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: userController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user  = res.user; //* Obtener el usuario autenticado

      if(user != null){
        //? 2. Si el usuario es valido verificamos su rol
        final String? rol =  user.userMetadata?['rol'];

        if(kIsWeb){
          //? Logica para web (Doctor)
          if (rol == 'doctor') {
            print('Login exitoso como Doctor');
            // Navegar a la vista del doctor
          }else{
            await supabase.auth.signOut();
            _mostrarError(context, "Acceso denegado: Los pacientes deben usar la App Móvil.");
          }
        }else{
          //? Logica para movil(Paciente)
          if(rol == 'paciente'){
            print("Bienvenido Paciente");
            // Navegar a la vista del paciente
          }else{
            await supabase.auth.signOut();
            _mostrarError(context, "Acceso denegado: Los doctores deben usar la versión web.");
          }
        }
      }
    }on AuthException catch(e){
      _mostrarError(context, e.message);
    } catch(e){
      _mostrarError(context, "Error inesperado: $e");
    }
  }

  //Funcion para mostrar errores
  void _mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error de Autenticación"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  // Limpieza de memoria
  void dispose() {
    userController.dispose();
    passwordController.dispose();
  }

}