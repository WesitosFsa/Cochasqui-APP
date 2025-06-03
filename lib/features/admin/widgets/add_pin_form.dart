import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPinForm extends StatefulWidget {
  final double lat;
  final double lng;
  final VoidCallback onSave;
  final Map<String, dynamic>? existingPin;

  const AddPinForm({
    super.key,
    required this.lat,
    required this.lng,
    required this.onSave,
    this.existingPin,
  });

  @override
  State<AddPinForm> createState() => _AddPinFormState();
}

class _AddPinFormState extends State<AddPinForm> {
  @override
  void initState() {
    super.initState();
    if (widget.existingPin != null) {
      titleController.text = widget.existingPin!['title'] ?? '';
      descController.text = widget.existingPin!['description'] ?? '';
      selectedType = widget.existingPin!['type'];
    }
  }

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? selectedType;

  final List<String> types = ['entrada', 'museo', 'pirámide', 'centro'];

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate() || selectedType == null) return;

    final data = {
      'title': titleController.text,
      'description': descController.text,
      'type': selectedType,
      'lat': widget.lat,
      'lng': widget.lng,
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
            Text('Añadir Pin en (${widget.lat.toStringAsFixed(5)}, ${widget.lng.toStringAsFixed(5)})'),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) => value!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tipo'),
              value: selectedType,
              items: types.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value),
              validator: (value) => value == null ? 'Selecciona un tipo' : null,
            ),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Guardar Pin'),
            ),
          ],
        ),
      ),
    );
  }
}
