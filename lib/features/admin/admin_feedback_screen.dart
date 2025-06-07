import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFeedbackScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const AdminFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<dynamic> _feedbackList = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarFeedback();
  }

  Future<void> cargarFeedback() async {
    setState(() {
      _cargando = true;
    });

    try {
      final res = await Supabase.instance.client
          .from('feedback')
          .select('id, user_id, mensaje, created_at, leido')
          .order('created_at', ascending: false);

      setState(() {
        _feedbackList = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar comentarios: $e')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> marcarComoLeido(int id) async {
    try {
      await Supabase.instance.client
          .from('feedback')
          .update({'leido': true})
          .eq('id', id);

      cargarFeedback(); // recargar para reflejar el cambio
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como leído: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios de usuarios'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _feedbackList.isEmpty
              ? const Center(child: Text('No hay retroalimentación aún'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _feedbackList.length,
                  itemBuilder: (context, index) {
                    final feedback = _feedbackList[index];
                    final leido = feedback['leido'] == true;

                    return Card(
                      color: leido ? Colors.grey[200] : Colors.white,
                      child: ListTile(
                        title: Text(feedback['mensaje']),
                        subtitle: Text(
                          'Usuario: ${feedback['user_id']}\nFecha: ${feedback['created_at']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: leido
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                tooltip: 'Marcar como leído',
                                onPressed: () {
                                  marcarComoLeido(feedback['id']);
                                },
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
