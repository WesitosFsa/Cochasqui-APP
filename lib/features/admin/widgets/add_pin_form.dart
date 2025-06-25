import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:cochasqui_park/shared/widgets/DropdownCamp.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPinForm extends StatefulWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onSave;
  final Map<String, dynamic>? existingPin;

  const AddPinForm({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onSave,
    this.existingPin,
  });

  @override
  State<AddPinForm> createState() => _AddPinFormState();
}

class _AddPinFormState extends State<AddPinForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? selectedType;

  final List<String> types = ['entrada', 'museo', 'piramide'];

  @override
  void initState() {
    super.initState();
    if (widget.existingPin != null) {
      titleController.text = widget.existingPin!['title'] ?? '';
      descController.text = widget.existingPin!['description'] ?? '';
      selectedType = normalizeType(widget.existingPin!['type']);
    }
  }

  String? normalizeType(String? value) {
    if (value == null) return null;
    String normalize(String s) => s.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    final normalizedValue = normalize(value);
    for (var type in types) {
      if (normalize(type) == normalizedValue) {
        return type;
      }
    }
    return null;
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate() || selectedType == null) return;

    final data = {
      'title': titleController.text,
      'description': descController.text,
      'type': selectedType,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
    };

    if (widget.existingPin != null) {
      await Supabase.instance.client
          .from('map_pins')
          .update(data)
          .eq('id', widget.existingPin!['id']);
    } else {
      await Supabase.instance.client.from('map_pins').insert(data);
    }

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            Text('Añadir Pin en (${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)})'),
            TextCamp(
              label: 'Título',
              controller: titleController,
              emptyAndSpecialCharValidation: true,
            ),
            TextCamp(
              label: 'Descripción',
              controller: descController,
              emptyAndSpecialCharValidation: true,
              maxLines: 5, // Allow the text field to expand vertically
              keyboardType: TextInputType.multiline, // Enable multi-line input
            ),
            DropdownCamp(
              label: 'Tipo',
              value: selectedType,
              items: types,
              onChanged: (value) => setState(() => selectedType = value),
              validator: (value) => value == null ? 'Selecciona un tipo' : null,
            ),
            ButtonR(onTap:_savePin,text: 'Guardar Pin',icon: Icons.save,color: AppColors.azulOscuro,),
          ],
        ),
      ),
    );
  }
}
