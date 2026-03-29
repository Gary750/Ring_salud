import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyService {

  Future<void> enviarSMS(String numero) async {
    try {
      final Uri uri = Uri.parse(
        "sms:$numero?body=🚨 Emergencia: necesito ayuda inmediata",
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        print("📩 Abriendo app de SMS...");
      } else {
        print("❌ No se pudo abrir SMS");
      }

    } catch (e) {
      print("❌ Error SMS: $e");
    }
  }

  Future<void> realizarLlamada(String numero) async {
    try {
      bool? res = await FlutterPhoneDirectCaller.callNumber(numero);

      if (res != true) {
        throw "No llamó";
      }

      print("📞 Llamada automática realizada");

    } catch (e) {
      print("⚠️ Llamada automática falló, abriendo marcador...");

      final Uri uri = Uri.parse("tel:$numero");
      await launchUrl(uri);
    }
  }
}