import 'package:cochasqui_park/core/config.dart';
import 'package:cochasqui_park/features/auth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para inicializaciones asíncronas
  await SupabaseConfig.init(); // Aquí inicializas Supabase

  runApp(const MyApp()); // Lanzas la app después de inicializar
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cochasqui Desarrollo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
      
    );
  }
}


