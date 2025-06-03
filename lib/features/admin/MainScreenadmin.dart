
import 'package:cochasqui_park/features/admin/ManageARadmin.dart';
import 'package:cochasqui_park/features/admin/ManageMapadmin.dart';
import 'package:cochasqui_park/features/main/screens/HomeScreen.dart';

import 'package:flutter/material.dart';

class MainScreenAdmin extends StatefulWidget {
  const MainScreenAdmin({super.key});

  @override
  State<MainScreenAdmin> createState() => _MainScreenAdmin();
}

class _MainScreenAdmin extends State<MainScreenAdmin> {
  List  screens = [
    HomeScreen(),
    ManageARadmin(),
    ManageMapadmin(),
    
  ];
  int currentIndex=0;
  void onTap(int index){
    setState(() {
      currentIndex = index;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: screens[currentIndex],
      backgroundColor: Color(0xFFECEBE9),
      bottomNavigationBar: BottomNavigationBar(

        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(185, 109, 109, 109),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items:[
          BottomNavigationBarItem(label: "Menu",icon: Icon(Icons.dashboard_customize)),
          BottomNavigationBarItem(label: "Editar AR",icon: Icon(Icons.view_in_ar)),
          BottomNavigationBarItem(label: "Editar Mapa",icon: Icon(Icons.map)),
        ]

      ),
    );
  }
}