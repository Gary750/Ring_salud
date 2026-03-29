import 'dart:typed_data'; // ✅ Para Int64List (Vibración)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; 
import 'dart:developer';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 1. Bandera para evitar inicializaciones dobles y errores de permisos
  static bool _isInitialized = false;

  static Future<void> init() async {
    // Si ya se inicializó en esta sesión, no hacemos nada más
    if (_isInitialized) {
      log("🔔 NotificationService ya estaba inicializado.");
      return;
    }

    tz.initializeTimeZones();
    
    try {
      final dynamic currentTimeZoneInfo = await FlutterTimezone.getLocalTimezone();
      
      String zoneName;
      if (currentTimeZoneInfo is String) {
        zoneName = currentTimeZoneInfo;
      } else {
        zoneName = currentTimeZoneInfo.identifier.toString();
      }

      tz.setLocalLocation(tz.getLocation(zoneName));
      log("✅ Zona horaria establecida: $zoneName");
    } catch (e) {
      log("⚠️ Error en Timezone: $e. Usando CDMX por defecto.");
      tz.setLocalLocation(tz.getLocation('America/Mexico_City')); 
    }

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Notificación tocada: ${response.payload}");
      },
    );

    // 2. Manejo seguro de permisos para evitar PlatformException
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      try {
        // Verificamos si las notificaciones están habilitadas antes de pedir
        final bool? areEnabled = await androidPlugin.areNotificationsEnabled();
        
        if (areEnabled == false || areEnabled == null) {
          log("📢 Solicitando permiso de notificaciones...");
          await androidPlugin.requestNotificationsPermission();
        }

        // Solicitamos permiso para alarmas exactas (Requerido en Android 12+)
        log("⏰ Solicitando permiso de alarmas exactas...");
        await androidPlugin.requestExactAlarmsPermission();
        
      } catch (e) {
        log("⚠️ Error al gestionar permisos de Android: $e");
      }
    }

    _isInitialized = true;
    log("🚀 NotificationService inicializado correctamente.");
  }

  static Future<void> cancelarTodasLasAlarmas() async {
    try {
      await _notifications.cancelAll();
      log("🧹 Limpieza completa: Se cancelaron todas las notificaciones.");
    } catch (e) {
      log("⚠️ Error al cancelar todas las alarmas: $e");
    }
  }

  static Future<void> cancelarAlarma(int id) async {
    await _notifications.cancel(id: id); 
    log("🔕 Alarma cancelada: $id");
  }

  static Future<void> programarAlarma(dynamic id, String nombreMed, DateTime hora) async {
    // Si la hora ya pasó, no programamos nada
    if (hora.isBefore(DateTime.now())) return;

    final int notificationId = id is int ? id : id.toString().hashCode;

    // Patrón de vibración: espera, vibra, espera, vibra...
    final Int64List vibrationPattern = Int64List.fromList([
      0, 1000, 500, 1000, 500, 1000, 1500, 500, 1000, 500, 1000, 500, 1000, 500, 1000, 1500
    ]);

    await _notifications.zonedSchedule(
      id: notificationId,
      title: '¡HORA DE TU MEDICAMENTO! 💊',
      body: 'Es momento de tomar: $nombreMed',
      scheduledDate: tz.TZDateTime.from(hora, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'med_alarms_v8',
          'Alertas de Medicación Críticas',
          channelDescription: 'Alarmas ruidosas para medicamentos',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // Esto ayuda a que aparezca sobre la pantalla de bloqueo
          playSound: true,
          ongoing: true,        
          autoCancel: false,    
          vibrationPattern: vibrationPattern, 
          enableVibration: true,
          setAsGroupSummary: false,
          groupAlertBehavior: GroupAlertBehavior.all,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: notificationId.toString(),
    );
    
    log("🚀 Alarma RUIDOSA programada: $nombreMed a las ${hora.toString()}");
  }
}