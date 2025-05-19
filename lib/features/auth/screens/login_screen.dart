
import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/screens/register_screen.dart';
import 'package:cochasqui_park/features/auth/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/fonts_bold.dart';
import 'package:cochasqui_park/features/main/screens/MainScreen.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
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

  void _login(BuildContext context) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final response = await AuthService().login(email, password);

      if (response.user != null) {
        // Login exitoso
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));

      } else {
        setState(() {
          _error = 'Error al iniciar sesión.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Correo o contraseña incorrectos.';
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
      backgroundColor: Color(0xFFECEBE9),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      text_bold(text: 'Registrate o accede como invitado',size: 16,),
                      const SizedBox(height: 35),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: "Correo Electronico"),
                        enabled: !_busy,
                        onFieldSubmitted: _busy
                            ? null
                            : (String value) {
                                _login(context);
                              },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: "Contraseña", errorText: _error),
                        enabled: !_busy,
                        onFieldSubmitted: _busy
                            ? null
                            : (String value) {
                                _login(context);
                              },
                      ),
                      // Texto de error 
                      const SizedBox(height: 25),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 25),
                      ButtonR(
                          text: "Iniciar Sesion",
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
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                       
                          }
               
                      ),
                      const SizedBox(height: 25),
                      ButtonR(
                          text: "Acceder como invitado",
                          showIcon: false,
                      )
      
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
