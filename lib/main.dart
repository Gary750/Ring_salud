import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Importación clave para separar Web de Móvil
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:provider/provider.dart'; 
import 'package:get/get.dart';

// --- IMPORTACIÓN DE CONTROLADORES Y VISTAS ---
import 'views/shared/auth_gate.dart'; 
import 'controllers/patient_mobile_controller.dart'; 
import 'views/mobile/profile/medical_recipe_view.dart';
import 'services/notification_service.dart'; // ✅ Importamos el servicio de alarmas

Future<void> main() async {
  // 1. Vincular Flutter con el motor nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargar variables de entorno (Seguridad)
  await dotenv.load(fileName: ".env");

  // 3. Inicialización de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // 4. Inicializar Notificaciones (¡SOLO PARA MÓVIL!)
  // Esto evita que la Web del doctor intente usar librerías nativas de Android y crashee.
  if (!kIsWeb) {
    try {
      await NotificationService.init();
      debugPrint("✅ Servicio de Notificaciones inicializado (Modo Móvil)");
    } catch (e) {
      debugPrint("❌ Error al iniciar Notificaciones: $e");
    }
  } else {
    debugPrint("💻 Modo Web detectado. Se omiten las alarmas locales.");
  }

  // 5. Inyectar dependencias y ejecutar la App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientController()),
        // Nota: Cuando necesites usar otros controladores de forma global, agrégalos aquí.
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
      
      // Lógica de selección de plataforma y sesión
      home: const AuthGate(),
      
      // Rutas de la aplicación
      routes: {
        '/medical-recipe': (context) => const MedicalRecipeView(),
      },
    );
  }
}