import 'package:cochasqui_park/core/powersync/powersync.dart';
import 'package:cochasqui_park/core/supabase/supabase.dart';
import 'package:cochasqui_park/features/admin/MainScreenadmin.dart';
import 'package:cochasqui_park/features/main/screens/MainScreen.dart';
import 'package:cochasqui_park/features/main/screens/welcome_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadSupabase();
  await openDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cochasquí Desarrollo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
      home: const _Router(),
    );
  }
}

/// Pantalla intermedia que decide a dónde enviar al usuario.
class _Router extends StatefulWidget {
  // ignore: unused_element_parameter
  const _Router({super.key});

  @override
  State<_Router> createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  /// true = cargando, false = listo
  bool _loading = true;
  Widget _nextScreen = const WelcomeScreen();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

Future<void> _checkSession() async {
  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;


  if (session != null) {
    final userId = session.user.id;

    try {
      final profileResponse = await supabase
          .from('profiles')
          .select() 
          .eq('id', userId)
          .maybeSingle();


      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (profileResponse != null) {
        final rol = profileResponse['rol'] as String? ?? 'user';

        userProvider.setUser(UserModel(
          id: session.user.id,
          email: session.user.email!,
          nombre: profileResponse['nombre'] as String?,
          apellido: profileResponse['apellido'] as String?,
          fechaNacimiento: profileResponse['fecha_nacimiento'] != null
              ? DateTime.tryParse(profileResponse['fecha_nacimiento'] as String)
              : null,
          genero: profileResponse['genero'] as String?,
          rol: rol,
          avatarUrl: profileResponse['avatar_url'] as String?,
        ));

        if (rol == 'admin') {
          _nextScreen = const MainScreenAdmin();
        } else {
          _nextScreen = const MainScreen();
        }
      } else {
        // Perfil no encontrado, redirigir a bienvenida o login
        _nextScreen = const WelcomeScreen();
      }
    } catch (e) {
      _nextScreen = const WelcomeScreen();
    }
  } else {
    _nextScreen = const WelcomeScreen();
  }

  if (mounted) setState(() => _loading = false);
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _nextScreen;
  }
}
