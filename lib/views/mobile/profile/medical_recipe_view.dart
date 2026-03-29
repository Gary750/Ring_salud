import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../services/pdf_service.dart';
import '../../../controllers/patient_mobile_controller.dart';

class MedicalRecipeView extends StatefulWidget {
  const MedicalRecipeView({super.key});

  @override
  State<MedicalRecipeView> createState() => _MedicalRecipeViewState();
}

class _MedicalRecipeViewState extends State<MedicalRecipeView> {
  File? pdfFile;
  bool loadingPdf = true;
  bool pdfGenerado = false; 

  Future<Map<String, dynamic>> _fetchRecipeWithPatientData() async {
    final supabase = Supabase.instance.client;
    final patientController =
        Provider.of<PatientController>(context, listen: false);
    final patient = patientController.patient;

    if (patient == null) {
      throw Exception("No se encontró información del paciente logueado.");
    }

    final recipeResponse = await supabase
        .from('receta')
        .select('*, paciente(*)')
        .eq('id_paciente', patient.idPaciente)
        .order('fecha', ascending: false)
        .limit(1)
        .maybeSingle();

    if (recipeResponse == null) {
      throw Exception("Aún no tienes recetas registradas.");
    }

    return recipeResponse;
  }

  Future<void> generarPdf(Map<String, dynamic> receta) async {
    try {
      setState(() => loadingPdf = true);

      final file = await PdfService.generateMedicalRecipe(receta);

      setState(() {
        pdfFile = file;
        loadingPdf = false;
      });
    } catch (e) {
      setState(() => loadingPdf = false);

      Get.snackbar("Error", "No se pudo generar el PDF: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D2C6C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Receta Médica",
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRecipeWithPatientData(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          }

          final receta = snapshot.data!;
          final nombrePaciente =
              receta['paciente']?['nombre'] ?? 'Sin nombre';

          if (!pdfGenerado) {
            pdfGenerado = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              generarPdf(receta);
            });
          }

          return Column(
            children: [

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: loadingPdf
                      ? const Center(child: CircularProgressIndicator())
                      : pdfFile == null
                          ? const Center(child: Text("No se pudo cargar el PDF"))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SfPdfViewer.file(pdfFile!),
                            ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      if (pdfFile == null) {
                        await generarPdf(receta);
                      }

                      await Printing.layoutPdf(
                        onLayout: (format) async =>
                            await pdfFile!.readAsBytes(),
                        name:
                            'Receta_${nombrePaciente.replaceAll(' ', '_')}',
                      );
                    } catch (e) {
                      Get.snackbar("Error", "$e",
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    }
                  },
                  icon: const Icon(Icons.print),
                  label: const Text("DESCARGAR / IMPRIMIR PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}