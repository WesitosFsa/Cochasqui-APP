// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore
import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/screens/register_screen_profile.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
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

  Future<void> _showVerificationDialog(BuildContext context, String email) async {
    final _codeController = TextEditingController();
    String? errorText;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _verifyCode() async {
              final code = _codeController.text.trim();

              if (code.isEmpty) {
                setState(() {
                  errorText = 'Ingresa el código de verificación';
                });
                return;
              }

              try {
                await Supabase.instance.client.auth.verifyOTP(
                  email: email,
                  token: code,
                  type: OtpType.signup,
                );

                if (mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo verificado. Ahora puedes registrar tus datos de perfil.')),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterScreenProfile()));
                }
              } on AuthException catch (e) {
                setState(() {
                  errorText = 'Código inválido o expirado. ${e.message}';
                });
              } catch (e) {
                setState(() {
                  errorText = 'Ocurrió un error al verificar el código.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Verifica tu correo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ingresa el código enviado a tu correo. Revisa tu bandeja de entrada y la carpeta de spam.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Código de verificación',
                      errorText: errorText,
                    ),
                    keyboardType: TextInputType.number, 
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text('Verificar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _signup(BuildContext context) async {
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
      final response = await AuthService().signUp(email, password);

      if (response.user != null) {
        await _showVerificationDialog(context, email);
      } else {
        setState(() {
          _error = 'Error desconocido al registrarse. Intenta de nuevo.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('User already registered')) {
          _error = 'El correo electrónico ya está registrado.';
        } else if (e.message.contains('Password should be at least 6 characters')) {
          _error = 'La contraseña debe tener al menos 6 caracteres (aunque TextCamp valida 8).';
        } else {
          _error = 'Error de registro: ${e.message}';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEBE9),
        elevation: 0,
        title: const Text("Registro", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)), // Usar TextStyle directamente
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                      text_bold(text: 'Regístrate aquí', size: 15),
                      const SizedBox(height: 35),
                      TextCamp(
                        label: "Correo Electrónico",
                        controller: _usernameController,
                        emailValidation: true, 
                        enabled: !_busy,
                        keyboardType: TextInputType.emailAddress, 
                        autovalidateMode: AutovalidateMode.onUserInteraction, 
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                },
                      ),
                      const SizedBox(height: 20),
                      TextCamp(
                        label: "Contraseña de registro",
                        controller: _passwordController,
                        obscureText: true,
                        passwordValidations: true, 
                        enabled: !_busy,
                        passwordView: true,
                        keyboardType: TextInputType.text, 
                        autovalidateMode: AutovalidateMode.onUserInteraction, 
                        onSubmitted: _busy
                            ? null
                            : (String value) {
                                },
                      ),
                      const SizedBox(height: 25),
                      if (_error != null) ...[ 
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                      ButtonR(
                        text: 'Registrarse',
                        showIcon: false,
                        onTap: () {
                          _signup(context); 
                        },
                      )
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