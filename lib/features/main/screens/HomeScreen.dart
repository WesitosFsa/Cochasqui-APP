import 'package:cochasqui_park/features/auth/screens/login_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:cochasqui_park/shared/widgets/fonts.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> with TickerProviderStateMixin {
  var imagenes = {
    "test1.jpg": "test1",
    "test2.jpg": "test2",
    "test3.jpg": "test3",
    "icono.png": "icono"
  };

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    TabController _tabController = TabController(length: 3, vsync: this);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >
        600; 

    return Scaffold(
      backgroundColor: const Color(0xFFECEBE9),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 50),
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Volver'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                userProvider.clearUser(); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, 
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.07,
                  left: screenWidth * 0.05), 
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon:
                          const Icon(Icons.menu, size: 30, color: Colors.black),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: screenWidth *
                        0.13, 
                    height: screenWidth *
                        0.13, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),

            SizedBox(
                height: screenHeight *
                    0.03), 
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05),
              child: text_bold(
                  text: 'Bienvenido',
                  size: isTablet ? 24 : 20),
            ),
            SizedBox(height: screenHeight * 0.025),

            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              dividerHeight: 0,
              indicatorColor: Colors.blueGrey,
              tabs: const [
                Tab(text: 'Noticias'),
                Tab(text: 'Informacion'),
                Tab(text: 'Camping'),
              ],
            ),

            SizedBox(
              height: screenHeight *
                  0.35, 
              width: double.infinity,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(
                            right: screenWidth * 0.04,
                            top: screenHeight * 0.015,
                            left: screenWidth * 0.04),
                        width: screenWidth *
                            0.55, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/test1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  const Center(child: Text("Contenido de Información")),
                  const Center(child: Text("Contenido de Camping")),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  text_bold(text: 'Mas opciones', size: isTablet ? 22 : 18),
                  text_simple(text: 'Ver todo', color: Colors.deepPurple),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.012),

            SizedBox(
              height: screenHeight * (isTablet ? 0.40 : 0.25),
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagenes.length,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                itemBuilder: (_, index) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: screenWidth * 0.04,
                      top: screenHeight * 0.015,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: DecorationImage(
                              // ignore: prefer_interpolation_to_compose_strings
                              image: AssetImage('assets/images/' +
                                  imagenes.keys.elementAt(index)),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        text_simple(
                            text: imagenes.values.elementAt(index),
                            color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
