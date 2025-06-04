import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:cochasqui_park/shared/widgets/DropdownCamp.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart';
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _emailController;
  String? _generoSeleccionado;
  final List<String> _generos = ['Masculino', 'Femenino', 'Otros'];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers(); 
  }

  void _initializeControllers() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _emailController = TextEditingController(text: user?.email ?? '');
    _nombreController = TextEditingController(text: user?.nombre ?? '');
    _apellidoController = TextEditingController(text: user?.apellido ?? '');
    _fechaNacimientoController = TextEditingController(
      text: user?.fechaNacimiento?.toIso8601String().split('T')[0] ?? '',
    );
    _generoSeleccionado = user?.genero;
  }
  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text =
            picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _initializeControllers();
      }
    });
  }

  void _guardarCambios() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    try {
      final Map<String, dynamic> updates = {
        'id': user.id,
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'fecha_nacimiento': _fechaNacimientoController.text.isNotEmpty
            ? _fechaNacimientoController.text
            : null,
        'genero': _generoSeleccionado,
      };

      final response = await Supabase.instance.client
          .from('profiles')
          .upsert(updates)
          .select()
          .single();

      userProvider.setUser(UserModel(
        id: user.id,
        email: user.email, 
        nombre: response['nombre'],
        apellido: response['apellido'],
        fechaNacimiento: response['fecha_nacimiento'] != null
            ? DateTime.parse(response['fecha_nacimiento'])
            : null,
        genero: response['genero'],
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente')),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),
          text_bold(
            text: 'Perfil de Usuario',
            size: 20,
          ),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/images/profile.png'), 
              backgroundColor: Colors.grey[300],
            ),
          ),
          SizedBox(height: 20),

          TextCamp(
              label: 'Email',
              controller: _emailController,
              readOnly: true,
              readType: true),
          SizedBox(height: 20),
          TextCamp(
            label: 'Nombre',
            controller: _nombreController,
            readOnly: !_isEditing, 
            readType: !_isEditing, 
          ),
          SizedBox(height: 20),
          TextCamp(
            label: 'Apellido',
            controller: _apellidoController,
            readOnly: !_isEditing, 
            readType: !_isEditing,
          ),
          SizedBox(height: 20),
          TextCamp(
            label: 'Fecha de Nacimiento',
            controller: _fechaNacimientoController,
            suffixIcon: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
            readOnly: !_isEditing,
            readType: !_isEditing, 
          ),
          SizedBox(height: 20),
            DropdownCamp(
            label: 'Género',
            value: _generoSeleccionado,
            items: _generos,
            onChanged: _isEditing
                ? (String? newValue) {
                    setState(() {
                      _generoSeleccionado = newValue;
                    });
                  }
                : (_) {},
            readType: !_isEditing, 
            readOnly: !_isEditing, 
          ),
          SizedBox(height: 20),
          _isEditing
              ? ButtonR(
                  color: AppColors.verde,
                  onTap: _guardarCambios,
                  text: 'Guardar Cambios',
                  showIcon: false)
              : ButtonR(
                  color: AppColors.azulMedio,
                  onTap: _toggleEditMode,
                  text: 'Editar Perfil',
                  showIcon: false),
          SizedBox(height: 20),
          if (_isEditing) 
            ButtonR(
              color: AppColors.rojo,
              onTap: () {
                setState(() {
                  _isEditing = false;
                  _initializeControllers(); 
                });
              },
              text: 'Cancelar',
              showIcon: false,

            ),
        ],
      ),
    );
  }
}