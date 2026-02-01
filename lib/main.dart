import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; //! Necesario para detectar la plataforma
import 'views/mobile/login_view_mobile.dart'; //! login de paciente
import 'views/web/login_view_web.dart';        //! Login del doctor
import 'package:supabase_flutter/supabase_flutter.dart'; //! Supabase

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //! Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://iliiejzqjupsqrvdqwqy.supabase.co', 
    anonKey: 'sb_publishable_cyBeWRRAW8ibIFW5iZEOuw_u7rwqe6I', 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ring Salud',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077C2)),
        useMaterial3: true,
      ),
      
      // 3. Lógica de selección de plataforma
      home: kIsWeb 
          ? const LoginViewWeb()     // Si se abre en navegador -> Va al panel del Doctor
          : const LoginViewMobile(), // Si es Android/iOS -> Va al Login del Paciente
    );
  }
}