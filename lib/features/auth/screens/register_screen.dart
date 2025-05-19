
import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/fonts_bold.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreene();
}

class _RegisterScreene extends State<RegisterScreen> {
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

  void _signup(BuildContext context) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (!email.contains('@')) {
    setState(() {
      _error = 'Ingresa un correo válido.';
    });
    }
    if (password.length < 6) {
    setState(() {
      _error = 'La contraseña debe tener al menos 6 caracteres.';
    });
    }
    try {
      final response = await AuthService().signUp(email, password);

      if (response.user != null) {
        
        if (mounted) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // Va al login
        }
      } else {
        setState(() {
          _error = 'Error al registrarse.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Debes llenar todos los campos';
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
                      text_bold(text: 'Registrate aqui' , size: 15,),
                      const SizedBox(height: 35),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: "Correo Electronico"),
                        enabled: !_busy,
                        onFieldSubmitted: _busy
                            ? null
                            : (String value) {
                                _signup(context);
                              },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: "Contraseña para nueva cuenta", errorText: _error),
                        enabled: !_busy,
                        onFieldSubmitted: _busy
                            ? null
                            : (String value) {
                                _signup(context);
                              },
                      ),
                      const SizedBox(height: 25),
                      ButtonR(
                        text: 'Registrarse',
                        showIcon: false,
                        //registro quemado sin coneccion a bdd por el momento
                        onTap: () {
                          _signup(context);
                        }
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
