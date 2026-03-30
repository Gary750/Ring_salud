# RING Salud

**RING Salud** es un ecosistema integral de salud y recordatorios de medicación diseñado para conectar a médicos y pacientes en tiempo real. Construido con **Flutter** y **Supabase**, el sistema se divide en dos plataformas sincronizadas: un **Panel Web** de control clínico para médicos y una **App Móvil** interactiva para pacientes.

## ✨ Características Principales

### 👨‍⚕️ Para el Médico (Panel Web)
* **Gestión de Pacientes:** Registro seguro de pacientes con generación de credenciales de acceso.
* **Control de Tratamientos:** Asignación de pautas médicas personalizadas (medicamento, dosis, frecuencia y duración).
* **Monitoreo en Tiempo Real:** Historial de adherencia al tratamiento (tomas confirmadas, retrasadas u omitidas).
* **Recetas Digitales:** Generación automática, visualización y descarga/impresión de recetas médicas en formato PDF.
* **Alertas de Emergencia:** Recepción de notificaciones SMS cuando un paciente activa el protocolo de emergencia.

### 📱 Para el Paciente (App Móvil)
* **Recordatorios Precisos:** Alarmas exactas e implacables para la toma de medicamentos (superando las restricciones de batería de Android 12+).
* **Confirmación de Tomas:** Interfaz intuitiva para registrar medicamentos como "Tomados", "Tarde" o visualizar los "Bloqueados".
* **Botón de Pánico (Protocolo de Emergencia):** Alerta instantánea que realiza una llamada automática e envía mensajes SMS de auxilio al contacto de emergencia y al médico tratante.
* **Receta en el Bolsillo:** Acceso en todo momento a la receta médica actual en formato PDF.
* **Soporte Offline:** Caché local que permite ver la información crucial aunque no haya conexión a internet.

---

## 🛠️ Stack Tecnológico

* **Framework:** [Flutter](https://flutter.dev/) (Soporte multiplataforma Web y Android)
* **Lenguaje:** Dart
* **Backend as a Service (BaaS):** [Supabase](https://supabase.com/) (Autenticación y Base de Datos PostgreSQL en tiempo real)
* **Gestión del Estado y Rutas:** GetX / Provider
* **Librerías Destacadas:**
  * `flutter_local_notifications`: Para las alarmas exactas en background.
  * `syncfusion_flutter_pdfviewer` & `printing`: Para el manejo avanzado de recetas.
  * `permission_handler`: Gestión robusta de permisos (SMS, Llamadas, Notificaciones).

---

## 🚀 Instalación y Configuración Local

Si deseas clonar y ejecutar este proyecto en tu máquina local, sigue estos pasos:

### 1. Prerrequisitos
Asegúrate de tener instalado Flutter SDK (versión más reciente recomendada) y configurar un entorno de emulador Android o dispositivo físico.

```bash
git clone [https://github.com/Gary750/Ring_salud.git](https://github.com/Gary750/Ring_salud.git)
cd Ring_salud
flutter pub get

### 2. Configuración de Variables de Entorno (.env)
Para proteger la conexión a la base de datos, las credenciales de Supabase se manejan mediante variables de entorno. Nunca subas tus API Keys al repositorio.

Crea un archivo llamado .env en la raíz del proyecto (al mismo nivel que tu pubspec.yaml).

Agrega tus credenciales de Supabase dentro del archivo con el siguiente formato:

SUPABASE_URL=tu_url_de_supabase_aqui
SUPABASE_ANON_KEY=tu_anon_key_de_supabase_aqui

  *Nota: El archivo main.dart ya está configurado para leer estas variables automáticamente al arrancar la app.