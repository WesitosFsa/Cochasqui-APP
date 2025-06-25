import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:cochasqui_park/shared/widgets/DropdownCamp.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/change_notifier_provider.dart'; 
import 'package:cochasqui_park/shared/widgets/fonts_bold.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

Future<void> subirImagen(BuildContext context) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;

  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Usuario no autenticado')),
    );
    return;
  }

  final fileExt = path.extension(pickedFile.path);
  final fileName = '${userId}_avatar$fileExt';
  final filePath = 'avatars/$fileName';

  final file = File(pickedFile.path);

  try {
    // ignore: unused_local_variable
    final response = await Supabase.instance.client.storage
        .from('avatars')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));
    final imageUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(filePath);
    await Supabase.instance.client
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', userId);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserModel = userProvider.user;
    if (currentUserModel != null) {
      userProvider.setUser(UserModel(
        id: currentUserModel.id,
        email: currentUserModel.email,
        nombre: currentUserModel.nombre,
        apellido: currentUserModel.apellido,
        fechaNacimiento: currentUserModel.fechaNacimiento,
        genero: currentUserModel.genero,
        rol: currentUserModel.rol, 
        avatarUrl: imageUrl, 
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen de perfil actualizada correctamente')),
    );
  } on StorageException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de Storage al subir imagen: ${e.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error general al subir imagen: $e')),
    );
  }
}
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
  String? _imagenSeleccionada; 
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
    _imagenSeleccionada = user?.avatarUrl; 
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ignore: unused_element
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
        rol: user.rol, 
        avatarUrl: _imagenSeleccionada, 
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
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
  Future<void> _handleImageUpload() async {
    await subirImagen(context);
    setState(() {
      _imagenSeleccionada = Provider.of<UserProvider>(context, listen: false).user?.avatarUrl;
    });
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    if (user?.avatarUrl != _imagenSeleccionada && !_isEditing) {
        _imagenSeleccionada = user?.avatarUrl;
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          text_bold(
            text: 'Perfil de Usuario',
            size: 20,
          ),
          Stack( 
            alignment: Alignment.bottomRight, 
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _imagenSeleccionada != null
                    ? NetworkImage('${_imagenSeleccionada!}?t=${DateTime.now().millisecondsSinceEpoch}')
                    : const AssetImage('assets/images/profile.png') as ImageProvider,

                backgroundColor: Colors.grey[300],
              ),
              if (_isEditing) 
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _handleImageUpload, 
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.azulMedio, 
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextCamp(
            label: 'Email',
            controller: _emailController,
            readOnly: true, 
            readType: true,
          ),
          const SizedBox(height: 20),
          TextCamp(
            label: 'Nombre',
            controller: _nombreController,
            readOnly: !_isEditing,
            readType: !_isEditing,
                        emptyAndSpecialCharValidation: true,

          ),
          const SizedBox(height: 20),
          TextCamp(
            label: 'Apellido',
            controller: _apellidoController,
            readOnly: !_isEditing,
            readType: !_isEditing,
                        emptyAndSpecialCharValidation: true,

          ),
          const SizedBox(height: 20),
          TextCamp(
            label: 'Fecha de Nacimiento',
            controller: _fechaNacimientoController,
            suffixIcon: const Icon(Icons.calendar_today),
            onTap: null, 
            readOnly: true, 
            readType: true,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          _isEditing
              ? ButtonR(
                  color: AppColors.verde,
                  onTap: _guardarCambios,
                  text: 'Guardar Cambios',
                  showIcon: false,
                )
              : ButtonR(
                  color: AppColors.azulMedio,
                  onTap: _toggleEditMode,
                  text: 'Editar Perfil',
                  showIcon: false,
                ),
          const SizedBox(height: 20),
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