// Importa el archivo de configuración de PowerSync
import 'package:cochasqui_park/core/powersync/powersync.dart';
import 'package:cochasqui_park/core/supabase/supabase.dart';
import 'package:cochasqui_park/features/main/screens/welcome_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier llamada asíncrona
  WidgetsFlutterBinding.ensureInitialized();

  await loadSupabase();

  await openDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
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