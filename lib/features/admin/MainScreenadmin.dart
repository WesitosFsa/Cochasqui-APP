import 'package:cochasqui_park/features/admin/ManageARadmin.dart';
import 'package:cochasqui_park/features/admin/ManageMapadmin.dart';
import 'package:cochasqui_park/features/admin/admin_feedback_screen.dart';
import 'package:cochasqui_park/features/main/screens/HomeScreen.dart';
import 'package:cochasqui_park/features/main/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart'; 
class MainScreenAdmin extends StatefulWidget {
  const MainScreenAdmin({super.key});

  @override
  State<MainScreenAdmin> createState() => _MainScreenAdmin();
}

class _MainScreenAdmin extends State<MainScreenAdmin> {
  int currentIndex = 0;

  final List screens = [
    HomeScreen(),
    ManageARadmin(),
    ManageMapadmin(),
    AdminFeedbackScreen(),
  ];

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, _) {
      final user = userProvider.user;

      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (user.rol != 'admin') {
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        });
        return const SizedBox(); 
      }

      return Scaffold(
        body: screens[currentIndex],
        backgroundColor: const Color(0xFFECEBE9),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTap,
          currentIndex: currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color.fromARGB(185, 109, 109, 109),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              label: "Menu",
              icon: Icon(Icons.dashboard_customize),
            ),
            BottomNavigationBarItem(
              label: "Editar AR",
              icon: Icon(Icons.view_in_ar),
            ),
            BottomNavigationBarItem(
              label: "Editar Mapa",
              icon: Icon(Icons.map),
            ),
            BottomNavigationBarItem(
              label: "Ver Feedback",
              icon: Icon(Icons.show_chart),
            ),
          ],
        ),
      );
    },
  );
}

}
