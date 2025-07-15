import 'package:cochasqui_park/features/auth/screens/login_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:cochasqui_park/features/feedback/feedback_screen.dart';
import 'package:cochasqui_park/shared/widgets/fonts.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;

  const HomeScreen({super.key, this.isGuest = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late bool _isGuest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isGuest = widget.isGuest;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Muestra la hoja inferior para todas las tarjetas horizontales (Noticias/Información/Camping)
  void _mostrarDetalle({
    required BuildContext context,
    required String titulo,
    required String descripcion,
    required String imagen,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/$imagen',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
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

  /// Descripciones inventadas para las "Más opciones"
  final Map<String, String> _descripcionOpciones = {
    "Pirámides":
        "Explora los vestigios milenarios de las pirámides de Cochasquí y siente la energía ancestral que aún se percibe en cada rincón. Un paseo ideal para los amantes de la historia y la arqueología.",
    "Llamas":
        "Conoce de cerca a nuestras adorables llamas, aliméntalas y aprende sobre su importancia cultural y económica en los Andes. ¡Una experiencia inolvidable para grandes y chicos!",
    "Camping":
        "Pasa una noche bajo las estrellas andinas. Nuestras áreas de camping cuentan con todas las comodidades necesarias para que tu estadía sea segura y confortable.",
    "Astroturismo":
        "El cielo despejado de Cochasquí te regalará una de las mejores vistas de la Vía Láctea. Únete a nuestras sesiones de astroturismo y descubre los secretos del universo.",
    "Cabañas":
        "Relájate en nuestras acogedoras cabañas de madera, rodeadas de naturaleza. El lugar perfecto para desconectar y recargar energías.",
    "Zona BBQ":
        "Comparte con familia y amigos en nuestra zona BBQ totalmente equipada. Parrillas, mesas y la mejor vista panorámica te esperan.",
  };

  /// Mapa imagen ➜ título
  final Map<String, String> _moreOptionsImages = {
    "Opcion1.png": "Pirámides",
    "Opcion2.png": "Llamas",
    "Opcion3.png": "Camping",
    "Opcion4.png": "Astroturismo",
    "Opcion5.png": "Cabañas",
    "AlpacaMan.png": "Zona BBQ",
  };

  @override
  Widget build(BuildContext context) {
    final userProvider = _isGuest ? null : Provider.of<UserProvider>(context);
    final currentUser = userProvider?.user;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    /* --------- CONTENIDO DE LAS LISTAS --------- */
    final List<Map<String, String>> noticias = [
      {
        "titulo": "¡Celebremos el Inti Raymi en Cochasquí!",
        "descripcion":
            "Este año, el Parque Arqueológico Cochasquí se prepara para celebrar el Inti Raymi, la Fiesta del Sol, con una serie de eventos culturales y tradicionales. ¡No te pierdas esta experiencia única!",
        "imagen": "Noticia1.png",
      },
    ];

    final List<Map<String, String>> informacion = [
      {
        "titulo": "¿Qué es Cochasquí?",
        "descripcion":
            "En Cochasquí tenemos presencia humana desde el periodo de integración (500 d.C. – 1500 d.C.). El museo Quilago exhibe piezas representativas de la cultura Caranqui y otras culturas andinas.",
        "imagen": "Informacion1.png",
      },
      {
        "titulo": "Convive con las Llamas",
        "descripcion":
            "Más de 60 llamas habitan nuestro parque. Las llamas, animales emblemáticos de la región andina, son criaturas dóciles y curiosas que se acercan a los visitantes.",
        "imagen": "Informacion2.png",
      },
      {
        "titulo": "Un espacio para compartir",
        "descripcion":
            "Disfruta de instalaciones como juegos infantiles, área de BBQ y espacios verdes. Escapa de la rutina con un paisaje sin igual.",
        "imagen": "Informacion3.png",
      },
    ];

    final List<Map<String, String>> campingInfo = [
      {
        "titulo": "Área de Camping",
        "descripcion": "Lunes a Domingo\n08h00 a 16h30",
        "imagen": "Camping1.png",
      },
      {
        "titulo": "Costo de Camping",
        "descripcion": "\$3.00 por persona. También alquilamos carpas, leña y carbón.",
        "imagen": "Camping3.png",
      },
    ];

    /* ------------- UI PRINCIPAL ------------- */
    return Scaffold(
      backgroundColor: const Color(0xFFECEBE9),
      drawer: _buildDrawer(context, currentUser),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(screenHeight, screenWidth, currentUser),
            _buildBienvenida(isTablet),
            _cardARPromo(screenWidth),
            SizedBox(height: screenHeight * 0.03),
            _tabs(screenWidth, noticias, informacion, campingInfo, screenHeight, isTablet),
            SizedBox(height: screenHeight * 0.03),
            _masOpcionesTitulo(screenWidth, isTablet),
            _masOpcionesLista(screenWidth, screenHeight),
            if (!_isGuest) _botonFeedback(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /* ---------------- COMPONENTES REUTILIZABLES ---------------- */

  Widget _buildDrawer(BuildContext context, dynamic currentUser) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 50),
        children: [
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Volver'),
            onTap: () => Navigator.pop(context),
          ),
          if (!_isGuest)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await Supabase.instance.client.auth.signOut();
                userProvider.clearUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          if (_isGuest)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Volver a la pantalla principal'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(double screenHeight, double screenWidth, dynamic currentUser) {
    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.07, left: screenWidth * 0.05),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Expanded(child: SizedBox()),
          if (!_isGuest)
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
                        '${currentUser!.avatarUrl}?t=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40),
                      ),
                    )
                  : const Icon(Icons.person, size: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildBienvenida(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text_bold(text: _isGuest ? 'Bienvenido Invitado' : 'Bienvenido', size: isTablet ? 24 : 20),
          const SizedBox(height: 4),
          text_simple(
            text: 'Explora Cochasquí de una forma distinta: noticias, camping y realidad aumentada te esperan.',
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _cardARPromo(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  text_bold(text: '¡Vive la experiencia en Realidad Aumentada!', size: 16),
                  SizedBox(height: 8),
                  text_simple(text: 'Descubre las pirámides como nunca antes.', size: 14),
                ],
              ),
            ),
            const Icon(Icons.view_in_ar, size: 48, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _tabs(
    double screenWidth,
    List<Map<String, String>> noticias,
    List<Map<String, String>> informacion,
    List<Map<String, String>> campingInfo,
    double screenHeight,
    bool isTablet,
  ) {
    Widget _horizontalCards(List<Map<String, String>> data) {
      return ListView.builder(
        itemCount: data.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = data[index];
          return GestureDetector(
            onTap: () => _mostrarDetalle(
              context: context,
              titulo: item['titulo']!,
              descripcion: item['descripcion']!,
              imagen: item['imagen']!,
            ),
            child: Container(
              margin: EdgeInsets.only(
                right: screenWidth * 0.04,
                top: screenHeight * 0.015,
                left: index == 0 ? screenWidth * 0.04 : 0,
              ),
              width: screenWidth * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/images/${item['imagen']!}'),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item['titulo']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          indicatorColor: Colors.blueGrey,
          tabs: const [Tab(text: 'Noticias'), Tab(text: 'Información'), Tab(text: 'Camping')],
        ),
        SizedBox(
          height: screenHeight * 0.35,
          child: TabBarView(
            controller: _tabController,
            children: [
              _horizontalCards(noticias),
              _horizontalCards(informacion),
              _horizontalCards(campingInfo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _masOpcionesTitulo(double screenWidth, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text_bold(text: 'Más opciones', size: isTablet ? 22 : 18),
          text_simple(text: 'Ver todo', color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _masOpcionesLista(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _moreOptionsImages.length,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        itemBuilder: (_, index) {
          final imagen = _moreOptionsImages.keys.elementAt(index);
          final titulo = _moreOptionsImages.values.elementAt(index);
          final descripcion = _descripcionOpciones[titulo] ?? 'Descripción próximamente';

          return GestureDetector(
            onTap: () => _mostrarDetalle(
              // ignore: no_wildcard_variable_uses
              context: _,
              titulo: titulo,
              descripcion: descripcion,
              imagen: imagen,
            ),
            child: Container(
              margin: EdgeInsets.only(right: screenWidth * 0.04, top: screenHeight * 0.015),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('assets/images/$imagen'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  text_simple(text: titulo, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _botonFeedback() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackScreen())),
        icon: const Icon(Icons.feedback),
        label: const Text('Dar feedback'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
