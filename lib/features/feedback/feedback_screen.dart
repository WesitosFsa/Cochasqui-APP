import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _mensajeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _enviando = false;

  Future<void> enviarFeedback() async {
    final mensaje = _mensajeController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;

    if (mensaje.isEmpty || user == null) return;

    setState(() {
      _enviando = true;
    });

    try {
      await Supabase.instance.client.from('feedback').insert({
        'user_id': user.id,
        'mensaje': mensaje,
      });

      _mensajeController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu retroalimentación!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar retroalimentación'),
      ),
      body: SingleChildScrollView( // <--- Added SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  '¿Tienes algún comentario o sugerencia?\nEscríbelo aquí:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mensajeController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El mensaje no puede estar vacío';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _enviando
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            enviarFeedback();
                          }
                        },
                  child: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}