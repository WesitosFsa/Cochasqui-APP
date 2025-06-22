import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/screens/verifypassword_screen.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart'; // Asegúrate de que TextCamp ya está actualizado
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importa AuthException si no está ya

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController();
  String? _message; 
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _message = 'Por favor, introduce un correo electrónico válido.';
      });
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _busy = true;
      _message = null; 
    });

    try {
      await AuthService().sendRecoveryCode(email);
      setState(() {
        _message = "Se ha enviado un código de recuperación a tu correo electrónico.";
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(email: email),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        // Mensajes de error específicos de Supabase en español
        if (e.message.contains('No user found for that email')) {
          _message = "No se encontró ningún usuario con ese correo electrónico. Por favor, verifica el correo.";
        } else if (e.message.contains('Email rate limit exceeded')) {
          _message = "Demasiados intentos. Por favor, espera un momento antes de intentarlo de nuevo.";
        } else {
          _message = "Error al enviar el código: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        _message = "Ocurrió un error inesperado al enviar el código. Por favor, inténtalo más tarde.";
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEBE9),
        elevation: 0,
        title: const Text(
          "Recuperar contraseña",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form( 
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text_bold(text: "Ingresa tu correo electrónico asociado a tu cuenta", size: 15), 
              const SizedBox(height: 20),
              TextCamp(
                label: 'Correo Electrónico', 
                controller: _emailController,
                emailValidation: true, 
                enabled: !_busy, 
                keyboardType: TextInputType.emailAddress, 
                autovalidateMode: AutovalidateMode.onUserInteraction, 
                onSubmitted: _busy
                    ? null
                    : (String value) {
                        _sendCode(); 
                      },
              ),
              const SizedBox(height: 30),
              ButtonR(
                text: "Enviar código",
                onTap: _busy ? null : _sendCode, 
                showIcon: false,
              ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("Error") || _message!.contains("No se encontró") ? Colors.red : Colors.green,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}