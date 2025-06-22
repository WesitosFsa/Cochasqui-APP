import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _busy = false;
  String? _message;

  void _verifyAndReset() async {
    final code = _codeController.text.trim();
    final newPass = _passwordController.text.trim();

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      await AuthService().verifyRecoveryCodeAndChangePassword(
        email: widget.email,
        token: code,
        newPassword: newPass,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado correctamente Ingresa de nuevo para poder disfrutar de la experiencia')),
      );

      await Future.delayed(Duration(seconds: 2)); 
      setState(() {
        
        _message = "Contraseña cambiada correctamente";
      });

      Navigator.popUntil(context, (route) => route.isFirst); 
    } catch (e) {
      setState(() {
        _message = "Código inválido o error al cambiar la contraseña";
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
      appBar: AppBar(
      backgroundColor: const Color(0xFFECEBE9), 
      elevation: 0, 
      title: text_bold(text: "Verificar codigo", size: 20), 
      iconTheme: const IconThemeData(color: Colors.black), 
    ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              text_bold(text: "Revisa tu correo y escribe el código recibido", size: 15),
              const SizedBox(height: 20),
              TextCamp(label: 'Código', controller: _codeController),
              const SizedBox(height: 20),
              TextCamp(
                label: "Nueva contraseña",
                controller: _passwordController,
                obscureText: true,
                passwordView: true,
                passwordValidations:true,
              ),
              const SizedBox(height: 30),
              ButtonR(
                text: "Cambiar contraseña",
                onTap: _busy ? null : _verifyAndReset,
                showIcon: false,
              ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(_message!),
              ]
            ],
          ),
        ),
      ),

    );
  }
}
