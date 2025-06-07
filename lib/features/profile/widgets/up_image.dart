import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> subirImagen(BuildContext context) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;

  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final fileExt = path.extension(pickedFile.path);
  final fileName = '${userId}_avatar$fileExt';
  final filePath = 'avatars/$fileName';

  final file = File(pickedFile.path);

  try {
    // ignore: unused_local_variable
    final response = await Supabase.instance.client.storage
        .from('avatars')
        .upload(filePath, file, fileOptions: FileOptions(upsert: true));

    final imageUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(filePath);

    await Supabase.instance.client
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imagen de perfil actualizada')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al subir imagen: $e')),
    );
  }
}
