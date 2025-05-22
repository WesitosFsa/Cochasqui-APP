// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore
import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/screens/register_screen_profile.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets//fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}
class _RegisterScreen extends State<RegisterScreen> {
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

  Future<void> _showVerificationDialog(BuildContext context, String email) async {
  final _codeController = TextEditingController();
  String? errorText;

  return showDialog(
    context: context,
    barrierDismissible: false, // no cerrar tocando afuera
    builder: (context) {
      return StatefulBuilder(
        
        builder: (context, setState) {
          // ignore: no_leading_underscores_for_local_identifiers
          Future<void> _verifyCode() async {
            final code = _codeController.text.trim();

            if (code.isEmpty) {
              setState(() {
                errorText = 'Ingresa el código de verificación';
              });
              return;
            }

            try {
              // Intentar verificar OTP
              await Supabase.instance.client.auth.verifyOTP(
                email: email,
                token: code,
                type: OtpType.signup,
              );

              Navigator.pop(context); 
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Correo verificado Ya puedes registrar tus datos para tu perfil.')),
                );
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const RegisterScreenProfile())); 
              }
            } catch (e) {
              setState(() {
                errorText = 'Código inválido, intenta de nuevo';
              });
            }
          }
          return AlertDialog(
            title: Text('Verifica tu correo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ingresa el código enviado a tu correo. Revisa spam o notificaciones.'),
                SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código de verificación',
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _verifyCode,
                child: Text('Verificar'),
              ),
            ],
          );
        },
      );
    },
  );
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
        _busy = false;
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _error = 'La contraseña debe tener al menos 6 caracteres.';
        _busy = false;
      });
      return;
    }

    try {
      final response = await AuthService().signUp(email, password);

      if (response.user != null || response.session == null) {
        // Aquí mostramos el dialog para ingresar el código de verificación
        await _showVerificationDialog(context, email);
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
      appBar: AppBar(
      backgroundColor: const Color(0xFFECEBE9), 
      elevation: 0, 
      title: text_bold(text: "Registro", size: 20), 
      iconTheme: const IconThemeData(color: Colors.black), 
    ),
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
                      TextCamp(
                        label: "Correo Electrónico",
                        controller: _usernameController,
                        enabled: !_busy,
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                _signup(context);
                              },
                      ),
                      const SizedBox(height: 20),
                      TextCamp(
                        label: "Contraseña de registro",
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_busy,
                        errorText: _error,
                        passwordView: true,
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                _signup(context);
                              },
                      ),
                      const SizedBox(height: 25),
                      ButtonR(
                        text: 'Registrarse',
                        showIcon: false,
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
