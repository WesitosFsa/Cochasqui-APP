import 'package:cochasqui_park/core/powersync/powersync.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'dart:async'; 

class FeedbackScreen extends StatefulWidget {
 
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _mensajeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _enviando = false;
  bool _isConnected = true; 

  late StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription; 

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity(); 
    _setupConnectivityListener(); 
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectivityStatus(connectivityResult);
  }

  void _setupConnectivityListener() {

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectivityStatus(results);
    });
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {

    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.bluetooth);

    if (_isConnected != hasConnection) {
      setState(() {
        _isConnected = hasConnection;
      });
      debugPrint('Estado de conexión actualizado: $_isConnected');
    }
  }

  Future<void> enviarFeedback() async {
    final mensaje = _mensajeController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;

    debugPrint('Intentando enviar feedback...');
    debugPrint('Mensaje: "$mensaje"');
    debugPrint('Usuario: ${user?.id}');


    if (mensaje.isEmpty || user == null) {
      debugPrint('Mensaje vacío o usuario no autenticado');
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      final idGenerado = '${DateTime.now().millisecondsSinceEpoch}_${user.id}';
      debugPrint('ID generado para feedback: $idGenerado');

      await db.execute('''
        INSERT INTO feedback(id, user_id, mensaje)
        VALUES(?, ?, ?)
      ''', [
        idGenerado,
        user.id,
        mensaje,
      ]);

      debugPrint('Feedback insertado exitosamente');

      _mensajeController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu retroalimentación!')),
      );
    } catch (e) {
      debugPrint('Error al insertar feedback: $e');
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
    _connectivitySubscription
        .cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retroalimentación'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(
              _isConnected
                  ? Icons.cloud
                  : Icons.cloud_off,
              color: _isConnected
                  ? Colors.grey
                  : Colors.red.shade700, 
              size: 28.0,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
