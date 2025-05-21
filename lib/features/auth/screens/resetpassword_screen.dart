import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/screens/verifypassword_screen.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _message;
  bool _busy = false;

  void _sendCode() async {
    final email = _emailController.text.trim();

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      await AuthService().sendRecoveryCode(email);
      setState(() {
        _message = "Código enviado al correo";
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: email),
        ),
      );
    } catch (e) {
      setState(() {
        _message = "Error al enviar el código";
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
      appBar: AppBar(title: Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Ingresa tu correo electrónico"),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            const SizedBox(height: 30),
            ButtonR(
              text: "Enviar código",
              onTap: _busy ? null : _sendCode,
              showIcon: false,
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(_message!),
            ]
          ],
        ),
      ),
    );
  }
}
