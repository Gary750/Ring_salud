import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //! Supabase
import 'package:flutter_dotenv/flutter_dotenv.dart'; //! Carga de variables de entorno
import 'package:provider/provider.dart'; //! IMPORTANTE: Agregar Provider
import 'views/shared/auth_gate.dart'; //! Pantalla de enrutamiento inteligente
import 'controllers/patient_mobile_controller.dart'; 
import 'package:get/get.dart';
import 'views/mobile/profile/medical_recipe_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  //! Inicialización de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // 1. Envolver runApp con MultiProvider para inyectar los controladores
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientController()),
        // Nota: Cuando necesites usar tus nuevos AlertsController o HistoryController de forma global,
        // simplemente los agregas en esta lista.
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ring Salud',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077C2)),
        useMaterial3: true,
      ),
      
      // Lógica de selección de plataforma
      home: const AuthGate(),
      routes: {
    '/medical-recipe': (context) => const MedicalRecipeView(),
  },
    );
  }
}