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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
   builder: (_) =>
     SingleChildScrollView(
      child: Padding(
       padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
       child: Column(
          // ELIMINA ESTA LÍNEA: mainAxisSize: MainAxisSize.min,
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
               errorBuilder: (context, error, stackTrace) {
                return Container(
                 height: 150,
                 color: Colors.grey[300],
                 child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                 ),
                );
               },
              ),
            ),
            const SizedBox(height: 10),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
          ],
       ),
      ),
   ),
  );
 }

  // Mapa de imágenes para la sección "Más opciones" (puedes ajustar estas)
  var moreOptionsImages = {
    "Opcion1.png":"Pirámides", 
    "Opcion2.png": "Llamas",
    "Opcion3.png": "Camping",
    "Opcion4.png":"Astroturismo", 
    "Opcion5.png": "Cabañas", 
    "AlpacaMan.png": "Zona BBQ", 
  };

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    // Contenido para la pestaña de Noticias
    final List<Map<String, String>> noticias = [
      {
        "titulo": "¡Celebremos el Inti Raymi en Cochasquí!",
        "descripcion":
            "Este año, el Parque Arqueológico Cochasquí se prepara para celebrar el Inti Raymi, la Fiesta del Sol, con una serie de eventos culturales y tradicionales. ¡No te pierdas esta experiencia única para conectar con nuestras raíces ancestrales y disfrutar de la música, danza y gastronomía andina! Mantente atento a nuestras redes sociales para el cronograma completo de actividades.",
        "imagen":
            "Noticia1.png", // Asegúrate de tener esta imagen en assets/images
      },
      // Puedes añadir más noticias aquí si las tienes
    ];

    // Contenido para la pestaña de Información
    final List<Map<String, String>> informacion = [
      {
        "titulo": "¿Qué es Cochasquí?",
        "descripcion":
            "En Cochasquí tenemos la presencia humana en el periodo de integración, periodo que comprende desde el 500 d.C. hasta el 1500 d.C. En el caso de Cochasquí, la datación radiocarbónica del sitio se divide en dos periodos: Cochasquí 1 (del 950 al 1250 d.C.) y Cochasquí 2 (del 1250 hasta 1550 d.C.), en el cual se incluye el periodo de ocupación inca del sitio. El museo de sitio Quilago exhibe piezas representativas del lugar, destacando la cultura Caranqui como principal, junto a otras culturas.",
        "imagen": "Informacion1.png", // O una imagen del museo
      },
      {
        "titulo": "Convive con las Llamas",
        "descripcion":
            "Más de 60 llamas en nuestro parque arqueológico. Las llamas, animales emblemáticos de la región andina, están emparentadas a los camellos y son criaturas dóciles y curiosas que a menudo se acercan a nuestros visitantes para que les brinden sal de su mano, siendo esta una gran oportunidad para fotografiarse junto a estos simpáticos animales.",
        "imagen": "Informacion2.png", // Una imagen de llamas
      },
      {
        "titulo": "Un espacio para compartir entre familia y amigos",
        "descripcion":
            "En un entorno seguro y familiar ideal para quienes prefieren algo más de facilidades en sus acampadas. Disponemos de instalaciones como juegos infantiles, área de BBQ, espacios verdes, rodeados de un paisaje sin igual; muy recomendable para quienes gustan escapar de la rutina sin alejarse demasiado de la ciudad fomentando un estilo de vida más activo.",
        "imagen": "Informacion3.png", // Una imagen de zona de camping/BBQ
      },
      {
        "titulo": "Ingreso al Parque Arqueológico",
        "descripcion": "Niños – \$0,50\nAdultos – \$1,00",
        "imagen": "Informacion5.png", // Un icono de ticket o dinero
      },
      {
        "titulo": "Horario de Atención",
        "descripcion":
            "Lunes a Domingo\n08h00 a 16h30\nÚltimo grupo guiado ingresa a las 15h00",
        "imagen": "Informacion4.png", // Un icono de reloj
      },
    ];

    // Contenido para la pestaña de Camping
    final List<Map<String, String>> campingInfo = [
      {
        "titulo": "Área de Camping",
        "descripcion": "Lunes a Domingo\n08h00 a 16h30",
        "imagen": "Camping1.png", // Un icono de camping
      },
      {
        "titulo": "Costo de Camping",
        "descripcion":
            "\$3.00 por persona\nAdemás contamos con alquiler de carpas, venta de leña y carbón… entre otros",
        "imagen": "Camping3.png", // Un icono de dinero
      },
      {
        "titulo": "Comodidades del Área de Camping",
        "descripcion":
            "Contamos con plataformas acondicionadas para que puedas armar tu carpa; encontrarás un área para hacer fogata o asado con tu propia parrilla y si no la tienes te podemos alquilar una.",
        "imagen": "Camping2.png", // Un icono de fogata o parrilla
      },
      {
        "titulo": "Zona BBQ",
        "descripcion":
            "Contamos con cuatro chozones equipados con parrillas, lavabo, mesa y basurero con una capacidad de hasta 10 personas en cada chozón.",
        "imagen": "Camping4.png", // Un icono de BBQ
      },
    ];

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
                  // Contenido de Noticias
                  ListView.builder(
                    itemCount: noticias.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final item = noticias[index];
                      return GestureDetector(
                        onTap: () {
                          mostrarDetalle(
                            context: context,
                            titulo: item["titulo"]!,
                            descripcion: item["descripcion"]!,
                            imagen: item["imagen"]!,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: screenWidth * 0.04,
                              top: screenHeight * 0.015,
                              left: (index == 0)
                                  ? screenWidth * 0.04
                                  : 0), // Adjust left margin for the first item
                          width: screenWidth * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/${item["imagen"]!}'),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Fallback to a placeholder icon if image fails to load
                                return; // Returning nothing uses the parent's background
                              },
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item["titulo"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Contenido de Información
                  ListView.builder(
                    itemCount: informacion.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final item = informacion[index];
                      return GestureDetector(
                        onTap: () {
                          mostrarDetalle(
                            context: context,
                            titulo: item["titulo"]!,
                            descripcion: item["descripcion"]!,
                            imagen: item["imagen"]!,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: screenWidth * 0.04,
                              top: screenHeight * 0.015,
                              left: (index == 0) ? screenWidth * 0.04 : 0),
                          width: screenWidth * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/${item["imagen"]!}'),
                              fit: BoxFit
                                  .cover, // Use cover for a good fit, or contain if it's an icon
                              onError: (exception, stackTrace) {
                                return;
                              },
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item["titulo"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Contenido de Camping
                  ListView.builder(
                    itemCount: campingInfo.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final item = campingInfo[index];
                      return GestureDetector(
                        onTap: () {
                          mostrarDetalle(
                            context: context,
                            titulo: item["titulo"]!,
                            descripcion: item["descripcion"]!,
                            imagen: item["imagen"]!,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: screenWidth * 0.04,
                              top: screenHeight * 0.015,
                              left: (index == 0) ? screenWidth * 0.04 : 0),
                          width: screenWidth * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/${item["imagen"]!}'),
                              fit: BoxFit
                                  .cover, // Use cover or contain depending on image type
                              onError: (exception, stackTrace) {
                                return;
                              },
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item["titulo"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
                itemCount: moreOptionsImages.length,
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
                                  'assets/images/${moreOptionsImages.keys.elementAt(index)}'),
                              fit: BoxFit.contain,
                              onError: (exception, stackTrace) {
                                return;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        text_simple(
                            text: moreOptionsImages.values.elementAt(index),
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
