import 'package:cochasqui_park/features/ar_experience/ar_loader.dart';
// ignore: unused_import
import 'package:cochasqui_park/features/feedback/feedback_screen.dart';
import 'package:cochasqui_park/features/profile/profile_screen.dart';
import 'package:cochasqui_park/features/main/screens/HomeScreen.dart';
import 'package:cochasqui_park/features/maps/map_screen.dart';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  late List<Widget> screens;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const ModelListLoaderScreen(),
      MapScreen(),
      ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorials(); 
    });
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    if (index == 1) {
      _checkAndShowARTutorial();
    }
    else if (index == 2) {
      _checkAndShowMapTutorial();
    }
    else if (index == 3) {
      _checkAndShowProfileTutorial();
    }
  }

  Future<void> _checkAndShowTutorials() async {
    final prefs = await SharedPreferences.getInstance();

    final hasSeenMainTutorial = prefs.getBool('has_seen_initial_tutorial') ?? false;
    if (!hasSeenMainTutorial) {
      await _showAlpacaTutorial(); 
      await prefs.setBool('has_seen_initial_tutorial', true);
    }

    final hasSeenHomeScreenTutorial = prefs.getBool('has_seen_home_screen_tutorial') ?? false;
    if (!hasSeenHomeScreenTutorial) {
      await _showHomeScreenTutorialInternal(); 
      await prefs.setBool('has_seen_home_screen_tutorial', true);
    }
  }

  Future<void> _showAlpacaTutorial() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/AlpacaMan.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Hola! Soy tu guía alpaca.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Bienvenido a Cochasquí Park! Aquí encontrarás el Mapa para explorar, experiencias de Realidad Aumentada y toda la información que necesitas. ¡Prepárate para la aventura! Usa el menú de abajo para navegar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67B044),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHomeScreenTutorialInternal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/AlpacaMan.png', 
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Bienvenido al Menú Principal!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aquí encontrarás noticias sobre el parque, información útil y detalles sobre la zona de camping. Explora las pestañas para ver todo lo que Cochasquí Park tiene para ofrecerte.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No olvides el botón "Dar feedback" al final para tus sugerencias.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67B044),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAndShowARTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenARTutorial = prefs.getBool('has_seen_ar_tutorial') ?? false;
    if (!hasSeenARTutorial) {
      await _showARTutorialInternal(); 
      await prefs.setBool('has_seen_ar_tutorial', true);
    }
  }

  Future<void> _showARTutorialInternal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/AlpacaMan.png', 
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Explora con Realidad Aumentada!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aquí podrás elegir entre explorar las pirámides o el museo con modelos 3D interactivos. Selecciona una zona, luego elige un modelo de la lista y escanea el código QR en el sitio para activar la experiencia AR.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Prepárate para ver el pasado de Cochasquí como nunca antes!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67B044),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    '¡A la aventura AR!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAndShowMapTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenMapTutorial = prefs.getBool('has_seen_map_tutorial') ?? false;
    if (!hasSeenMapTutorial) {
      await _showMapTutorialInternal(); 
      await prefs.setBool('has_seen_map_tutorial', true);
    }
  }

  Future<void> _showMapTutorialInternal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/AlpacaMan.png', 
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Descubre el Parque con el Mapa!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'En esta sección, podrás navegar por el mapa interactivo de Cochasquí Park. Identifica los puntos de interés, descubre sus ubicaciones y visualiza dónde se encuentran los códigos QR para las experiencias de Realidad Aumentada.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Planifica tu recorrido y no te pierdas nada!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67B044),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    '¡Explorar el Mapa!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAndShowProfileTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenProfileTutorial = prefs.getBool('has_seen_profile_tutorial') ?? false;
    if (!hasSeenProfileTutorial) {
      await _showProfileTutorialInternal(); 
      await prefs.setBool('has_seen_profile_tutorial', true);
    }
  }

  Future<void> _showProfileTutorialInternal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/AlpacaMan.png', 
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Tu Perfil, Tu Espacio!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aquí puedes personalizar tu experiencia. Edita tu información personal, actualiza tu foto de perfil y gestiona tus preferencias para que tu visita a Cochasquí Park sea aún mejor.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Hazlo tuyo y mantén tus datos al día!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67B044),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    '¡Listo!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      backgroundColor: const Color(0xFFECEBE9),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(185, 109, 109, 109),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(label: "Menu", icon: Icon(Icons.dashboard_customize)),
          BottomNavigationBarItem(label: "AR", icon: Icon(Icons.view_in_ar)),
          BottomNavigationBarItem(label: "Mapa", icon: Icon(Icons.map)),
          BottomNavigationBarItem(label: "Perfil", icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}