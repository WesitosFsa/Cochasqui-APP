import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/admin/MainScreenadmin.dart';
import 'package:cochasqui_park/features/auth/screens/register_screen.dart';
import 'package:cochasqui_park/features/auth/screens/resetpassword_screen.dart';
import 'package:cochasqui_park/features/guest/MainScreenG.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/features/main/screens/MainScreen.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); 
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  String? _error;
  late bool _busy;

  @override
  void initState() {
    super.initState();
    _busy = false;
    _passwordController = TextEditingController(text: '');
    _usernameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _error = 'Por favor, corrige los errores en el formulario.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null; 
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await AuthService().login(email, password);
      if (response.user == null) {
        throw Exception('Usuario no encontrado o credenciales inválidas.');
      }

      Map<String, dynamic> profileData = {};
      try {
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        profileData = profileResponse ?? {};
      // ignore: empty_catches
      } catch (e) {
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.setUser(UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        nombre: profileData['nombre'] as String?,
        apellido: profileData['apellido'] as String?,
        fechaNacimiento: profileData['fecha_nacimiento'] != null
            ? DateTime.tryParse(profileData['fecha_nacimiento'] as String)
            : null,
        genero: profileData['genero'] as String?,
        rol: profileData['rol'] as String?,
        avatarUrl: profileData['avatar_url'] as String?,
      ));

      final rol = (profileData['rol'] as String?) ?? 'usuario'; 

      if (rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreenAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('Invalid login credentials')) {
          _error = 'Correo electrónico o contraseña incorrectos.';
        } else if (e.message.contains('Email not confirmed')) {
          _error = 'Por favor, confirma tu correo electrónico para iniciar sesión.';
        } else {
          _error = 'Error de autenticación: ${e.message}';
        }
      });
    } on Exception catch (e) {
      setState(() {
        _error = 'Ocurrió un error inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBE9),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SizedBox(
                width: 300,
                child: Form( 
                  key: _formKey, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      text_bold(
                        text: 'Inicia Sesión o Accede como Invitado', 
                        size: 16,
                      ),
                      const SizedBox(height: 35),
                      TextCamp(
                        label: "Correo Electrónico",
                        controller: _usernameController,
                        enabled: !_busy,
                        emailValidation: true, 
                        keyboardType: TextInputType.emailAddress, 
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                },
                      ),
                      const SizedBox(height: 20),
                      TextCamp(
                        label: "Contraseña",
                        controller: _passwordController,
                        passwordValidations: true, 
                        obscureText: true,
                        enabled: !_busy,
                        passwordView: true,
                        keyboardType: TextInputType.visiblePassword, 
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                },
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()));
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 25),
                      ButtonR(
                        text: "Iniciar Sesión", 
                        showIcon: false,
                        onTap: () => _login(context), 
                      ),
                      const SizedBox(height: 25),
                      ButtonR(
                          text: "Registrarse",
                          showIcon: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          }),
                      const SizedBox(height: 25),
                      ButtonR(
                          text: "Acceder como invitado",
                          showIcon: false,
                          onTap: () {
                            Provider.of<UserProvider>(context, listen: false).clearUser();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreenGuests()),
                            );
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}