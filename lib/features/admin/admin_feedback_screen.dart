import 'package:cochasqui_park/features/admin/models/Users.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';


class AdminFeedbackScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const AdminFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> with SingleTickerProviderStateMixin {
  List<UserFeedback> _allFeedbackList = []; 
  bool _cargando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    cargarFeedback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cargarFeedback() async {
    setState(() {
      _cargando = true;
    });

    try {
      final List<dynamic> res = await Supabase.instance.client
          .from('feedback')
          .select('id, user_id, mensaje, created_at, leido, profiles(nombre, apellido, id)')
          .order('created_at', ascending: false);

      setState(() {
        _allFeedbackList = res.map((json) => UserFeedback.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar comentarios: $e')),
        );
      }
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> marcarComoLeido(String id) async {
    try {
      await Supabase.instance.client
          .from('feedback')
          .update({'leido': true})
          .eq('id', id);

      setState(() {

        final index = _allFeedbackList.indexWhere((f) => f.id == id);
        if (index != -1) {
          _allFeedbackList[index].leido = true; 
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al marcar como leído: $e')),
        );
      }
    }
  }

  Widget _buildFeedbackList(List<UserFeedback> feedbackList) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    } else if (feedbackList.isEmpty) {
      return const Center(child: Text('No hay retroalimentación para esta categoría.'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: feedbackList.length,
        itemBuilder: (context, index) {
          final feedback = feedbackList[index];
          final leido = feedback.leido;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            color: leido ? Colors.grey[200] : Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(
                feedback.mensaje,
                style: TextStyle(
                  fontWeight: leido ? FontWeight.normal : FontWeight.bold,
                  color: leido ? Colors.grey[600] : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Usuario: ${feedback.user?.fullName ?? 'Usuario Desconocido'}\nFecha: ${DateFormat('yyyy-MM-dd HH:mm').format(feedback.createdAt.toLocal())}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: leido
                  ? const Icon(Icons.check_circle_outline, color: Colors.green, size: 28)
                  : IconButton(
                      icon: const Icon(Icons.mark_email_unread, color: Colors.blue, size: 28),
                      tooltip: 'Marcar como leído',
                      onPressed: () {
                        marcarComoLeido(feedback.id);
                      },
                    ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadFeedback = _allFeedbackList.where((f) => !f.leido).toList();
    final readFeedback = _allFeedbackList.where((f) => f.leido).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios de usuarios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'No Leídos'),
            Tab(text: 'Leídos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackList(unreadFeedback),
          _buildFeedbackList(readFeedback),
        ],
      ),
    );
  }
}