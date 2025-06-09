import 'package:cochasqui_park/features/auth/screens/login_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:cochasqui_park/features/feedback/feedback_screen.dart';
import 'package:cochasqui_park/shared/widgets/fonts.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
  
}

class _HomeScreen extends State<HomeScreen> with TickerProviderStateMixin {

  void mostrarDetalle({
    required BuildContext context,
    required String titulo,
    required String descripcion,
    required String imagen,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/$imagen',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  var imagenes = {
    "test1.jpg": "test1",
    "test2.jpg": "test2",
    "test3.jpg": "test3",
    "icono.png": "icono"
  };
  

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;
    TabController _tabController = TabController(length: 3, vsync: this);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

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
              onTap: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await Supabase.instance.client.auth.signOut();
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
                  top: screenHeight * 0.07, left: screenWidth * 0.05),
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
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                    child: currentUser?.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${currentUser!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person,
                                    size: 40, color: Colors.white);
                              },
                            ),
                          )
                        : const Icon(Icons.person,
                            size: 40, color: Colors.white),
                  )
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05),
              child: text_bold(text: 'Bienvenido', size: isTablet ? 24 : 20),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, vertical: 8),
              child: text_simple(
                text:
                    'Explora Cochasquí de una forma distinta: noticias, camping y realidad aumentada te esperan.',
                size: 14,
                color: Colors.black87,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text_bold(
                              text:
                                  '¡Vive la experiencia en Realidad Aumentada!',
                              size: isTablet ? 18 : 16),
                          const SizedBox(height: 8),
                          text_simple(
                              text: 'Descubre las pirámides como nunca antes.',
                              size: 14),
                        ],
                      ),
                    ),
                    const Icon(Icons.view_in_ar,
                        size: 48, color: Colors.deepPurple)
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

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
              height: screenHeight * 0.35,
              width: double.infinity,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final imagen = 'test${index + 1}.jpg';
                      final titulo = 'Noticia ${index + 1}';
                      final descripcion =
                          'Esta es una descripción breve para la noticia ${index + 1}.';

                      return GestureDetector(
                        onTap: () {
                          mostrarDetalle(
                            context: context,
                            titulo: titulo,
                            descripcion: descripcion,
                            imagen: imagen,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: screenWidth * 0.04,
                              top: screenHeight * 0.015,
                              left: screenWidth * 0.04),
                          width: screenWidth * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage('assets/images/$imagen'),
                              fit: BoxFit.cover,
                            ),
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
                  text_bold(text: 'Más opciones', size: isTablet ? 22 : 18),
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
                              image: AssetImage(
                                  'assets/images/${imagenes.keys.elementAt(index)}'),
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

            SizedBox(height: screenHeight * 0.03),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => FeedbackScreen()));
                },
                icon: const Icon(Icons.feedback),
                label: const Text("Dar feedback"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
