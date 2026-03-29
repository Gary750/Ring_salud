import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generateMedicalRecipe(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/images/caduceo.png');
    final pw.MemoryImage caduceoImage =
        pw.MemoryImage(logoData.buffer.asUint8List());

    final nombre = data['paciente']?['nombre'] ?? 'N/A';
    final edad = data['edad']?.toString() ?? 'N/A';
    final sexo = data['sexo'] ?? 'N/A';
    final peso = data['peso']?.toString() ?? 'N/A';
    final talla = data['talla']?.toString() ?? 'N/A';
    final temp = data['temperatura']?.toString() ?? 'N/A';
    final ta = data['tension_arterial'] ?? 'N/A';
    final fc = data['frecuencia_cardiaca'] ?? 'N/A';
    final spo2 = data['spo2']?.toString() ?? 'N/A';
    final glucosa = data['glucosa']?.toString() ?? 'N/A';
    final alergias = data['paciente']?['alergias'] ?? 'NEGADAS';
    final fecha = data['fecha'] ?? 'N/A';
    final prescripcion =
        data['descripcion'] ?? 'No hay indicaciones médicas registradas.';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            children: [

              pw.Container(
                height: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                            width: 55,
                            height: 55,
                            child: pw.Image(caduceoImage)),
                        pw.Expanded(
                          child: pw.Column(
                            children: [
                              pw.Text("UNIDAD MÉDICA",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 13)),
                              pw.Text('"NUESTRO SEÑOR DE LAS MARAVILLAS"',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 13)),
                              pw.Text("Dr. Martín Trigueros Vizzuett",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 15,
                                      fontStyle: pw.FontStyle.italic)),
                              pw.Text(
                                  "UNIVERSIDAD AUTONOMA DEL ESTADO DE HIDALGO",
                                  style: pw.TextStyle(fontSize: 8)),
                              pw.Text(
                                  "MEDICINA GENERAL-CIRUGIA-PARTOS-NIÑOS",
                                  style: pw.TextStyle(fontSize: 8)),
                              pw.Text(
                                  "R.F.C. TVM-660102-A82     CEDULA PROFESIONAL 1890573",
                                  style: pw.TextStyle(fontSize: 8)),
                              pw.Text("S.S.A.: AF 02224-07",
                                  style: pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(height: 4),
                              pw.Text("MEDICO CIRUJANO",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        pw.Container(
                            width: 55,
                            height: 55,
                            child: pw.Image(caduceoImage)),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    _buildUnderlinedField(
                        "Nombre del paciente:", nombre, 1.0),
                    pw.SizedBox(height: 6),

                    pw.Row(children: [
                      _buildUnderlinedField("Edad:", edad, 0.25),
                      _buildUnderlinedField("Sexo:", sexo, 0.25),
                      _buildUnderlinedField("Peso:", "$peso kg", 0.25),
                      _buildUnderlinedField("Talla:", talla, 0.25),
                    ]),

                    pw.SizedBox(height: 6),

                    pw.Row(children: [
                      _buildUnderlinedField("Temp:", "$temp °C", 0.25),
                      _buildUnderlinedField("T/A:", ta, 0.25),
                      _buildUnderlinedField("FC:", fc, 0.25),
                      _buildUnderlinedField("SpO2:", "$spo2%", 0.25),
                    ]),

                    pw.SizedBox(height: 6),

                    pw.Row(children: [
                      _buildUnderlinedField("Glucosa:", glucosa, 0.33),
                      _buildUnderlinedField("Alergias:", alergias, 0.33),
                      _buildUnderlinedField("Fecha:", fecha, 0.33),
                    ]),
                  ],
                ),
              ),

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    pw.Divider(thickness: 1.5),

                    pw.Text("PRESCRIPCIÓN MÉDICA:",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),

                    pw.SizedBox(height: 10),

                    pw.Expanded(
                      child: pw.Container(
                        width: double.infinity,
                        child: pw.Text(
                          prescripcion,
                          style: pw.TextStyle(fontSize: 11),
                          textAlign: pw.TextAlign.justify,
                        ),
                      ),
                    ),

                    pw.Divider(),

                    pw.Center(
                      child: pw.Column(children: [
                        pw.Text(
                            "CONSULTA DE LUNES A VIERNES DE 10 A 5 PM, SABADOS DE 8 A 3 PM Y DOMINGOS (HABLAR ANTES)",
                            style: pw.TextStyle(fontSize: 7)),
                        pw.Text(
                            "Adolfo López Mateos No. 20 (entre Benito Juárez y Pino Suárez)",
                            style: pw.TextStyle(fontSize: 7)),
                        pw.Text("Cel. 7731216932 o 2221103038",
                            style: pw.TextStyle(fontSize: 7)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receta_completa.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildUnderlinedField(
      String label, String value, double flex) {
    return pw.Expanded(
      flex: (flex * 100).toInt(),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Text(value,
                  style: pw.TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}