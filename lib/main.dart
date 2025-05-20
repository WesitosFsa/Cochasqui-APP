import 'package:cochasqui_park/core/config.dart';
import 'package:cochasqui_park/features/auth/screens/welcome_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await SupabaseConfig.init(); 

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


