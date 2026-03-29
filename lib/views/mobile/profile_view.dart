import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../controllers/patient_mobile_controller.dart';
import '../../services/notification_service.dart'; 

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  bool _mostrarPassword = false;
  bool _sinInternet = false;
  bool _mostrandoAnimacion = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late StreamSubscription<List<ConnectivityResult>> _conexionSub;

  @override
  void initState() {
    super.initState();

    _init();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(_animationController);

    _animationController.forward();
  }

  Future<void> _init() async {
    await _checkConexion();

    if (!_sinInternet) {
      if (!mounted) return;
      Provider.of<PatientController>(context, listen: false)
          .loadPatientProfile();
    }

    _listenConexion();
  }

  Future<void> _checkConexion() async {
    final hayInternet = await InternetConnectionChecker.createInstance().hasConnection;

    if (!mounted) return;

    setState(() {
      _sinInternet = !hayInternet;
    });
  }

  void _listenConexion() {
    _conexionSub = Connectivity().onConnectivityChanged.listen((_) async {
      final hayInternet = await InternetConnectionChecker.createInstance().hasConnection;

      if (!mounted) return;

      if (hayInternet && _sinInternet) {
        setState(() {
          _sinInternet = false;
          _mostrandoAnimacion = true;
        });

        Provider.of<PatientController>(context, listen: false)
            .loadPatientProfile();

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _mostrandoAnimacion = false;
            });
          }
        });
      }

      if (!hayInternet) {
        setState(() {
          _sinInternet = true;
        });
      }
    });
  }

  Future<void> _handleLogout(PatientController controller) async {
    await NotificationService.cancelarTodasLasAlarmas();
    
    if (mounted) {
      controller.logout(context);
    }
  }

  @override
  void dispose() {
    _conexionSub.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PatientController>(context);
    final patient = controller.patient;
    final size = MediaQuery.of(context).size;

    const Color primaryBlue = Color(0xFF0D2C6C);

    if (_sinInternet) {
      return _buildNoInternet(controller);
    }

    if (controller.isLoading && patient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (patient == null) {
      return _buildNoData(controller);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Perfil del paciente",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildInfoBanner(),

                      const SizedBox(height: 20),

                      _buildHeaderCard(patient),

                      const SizedBox(height: 25),

                      const Text("Información personal",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primaryBlue)),

                      const SizedBox(height: 15),

                      _buildInfoItem(Icons.person, "Nombre", patient.nombre ?? "No disponible"),
                      _buildInfoItem(
                          Icons.cake, "Edad", "${patient.edad ?? 0} años"),

                      const SizedBox(height: 25),

                      const Text("Datos médicos",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primaryBlue)),

                      const SizedBox(height: 15),

                      _buildInfoItem(Icons.medical_services, "Diagnóstico",
                          patient.enfermedad ?? "No disponible"),
                      _buildInfoItem(Icons.warning_amber, "Alergias",
                          patient.alergias ?? "No especificado"),
                      _buildInfoItem(Icons.phone, "Teléfono", patient.telefono ?? "No disponible"),

                      const SizedBox(height: 5),
                      _buildRecipeButton(context),

                      const SizedBox(height: 25),

                      const Text("Acceso",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primaryBlue)),

                      const SizedBox(height: 10),

                      _buildPasswordRow(patient),

                      const SizedBox(height: 30),

                      Center(child: _buildLogoutButton(controller)),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          "Si no cierras sesión, permanecerás conectado.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            if (_mostrandoAnimacion)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "Conexión restaurada",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecipeButton(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D2C6C);

    return GestureDetector(
      onTap: () {
        Provider.of<PatientController>(context, listen: false)
            .openMedicalRecipe();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf,
                  color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                "Ver Receta Médica",
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternet(PatientController controller) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 90, color: Colors.red),
            const SizedBox(height: 20),
            const Text("Sin conexión a internet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _checkConexion();
                if (!_sinInternet) {
                  controller.loadPatientProfile();
                }
              },
              child: const Text("Reintentar"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _handleLogout(controller),
              child: const Text("Cerrar sesión",
                  style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoData(PatientController controller) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No se encontraron datos del paciente"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleLogout(controller),
              child: const Text("Cerrar sesión"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(patient) {
    String iniciales = "PA";
    if (patient.nombre != null && patient.nombre.length >= 2) {
      iniciales = patient.nombre.substring(0, 2).toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF64B5F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFF0D67EE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  patient.nombre ?? "Sin nombre",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Paciente ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(PatientController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(controller),
        icon: const Icon(Icons.logout),
        label: const Text("Cerrar sesión"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Contacta a tu médico si hay errores en tu información.",
              style: TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF42A5F5)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2C6C),
                        fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow(patient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF42A5F5)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _mostrarPassword
                  ? _ocultarUltimosTres(patient.contrasena ?? "")
                  : "••••••••",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0D2C6C)),
            ),
          ),
          IconButton(
            icon: Icon(
                _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey),
            onPressed: () {
              setState(() {
                _mostrarPassword = !_mostrarPassword;
              });
            },
          )
        ],
      ),
    );
  }

  String _ocultarUltimosTres(String password) {
    if (password.length <= 3) return "•••";
    return "${password.substring(0, password.length - 3)}***";
  }
}