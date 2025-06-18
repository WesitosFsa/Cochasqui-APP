import 'package:cochasqui_park/features/admin/MainScreenDashboardadmin.dart';
import 'package:cochasqui_park/features/admin/ManageARadmin.dart';
import 'package:cochasqui_park/features/admin/ManageMapadmin.dart';
import 'package:cochasqui_park/features/admin/admin_feedback_screen.dart';
import 'package:cochasqui_park/features/main/screens/welcome_screen.dart'; 
import 'package:cochasqui_park/features/stats/stats_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';

class MainScreenAdmin extends StatefulWidget {
  const MainScreenAdmin({super.key});

  @override
  State<MainScreenAdmin> createState() => _MainScreenAdminState(); 
}

class _MainScreenAdminState extends State<MainScreenAdmin> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const AdminDashboardScreen(), 
    const StatisticsScreen(),   
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
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            type: BottomNavigationBarType.fixed, 
            items: const [
              BottomNavigationBarItem(
                label: "Inicio", 
                icon: Icon(Icons.home), 
              ),
              BottomNavigationBarItem(
                label: "Estadísticas",
                icon: Icon(Icons.bar_chart),
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
                label: "Feedback", 
                icon: Icon(Icons.feedback), 
              ),
            ],
          ),
        );
      },
    );
  }
}