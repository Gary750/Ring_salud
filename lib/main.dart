import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //! Supabase
import 'views/shared/auth_gate.dart'; //! Pantalla de enrutamiento inteligente

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //! Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://your-project.supabase.co', // Reemplaza con tu URL de Supabase
    anonKey: 'your-anon-key', // Reemplaza con tu clave anónima de Supabase

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