import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //! Supabase
import 'views/shared/auth_gate.dart'; //! Pantalla de enrutamiento inteligente
import 'package:flutter_dotenv/flutter_dotenv.dart'; //! Carga de variables de entorno

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //! Inicialización de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(MyApp());
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
      home: const AuthGate(),
    );
  }
}