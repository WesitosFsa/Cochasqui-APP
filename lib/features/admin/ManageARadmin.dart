import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageARadmin extends StatefulWidget {
  const ManageARadmin({super.key});
  @override

  _ManageARadminState createState() => _ManageARadminState();
}

class _ManageARadminState extends State<ManageARadmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController riddleController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  String? selectedCategory;
  String? selectedKey;

  final Map<String, List<String>> categoryKeys = {
    'museo': ['Modelo1', 'Modelo2', 'Modelo3', 'Modelo4', 'Modelo5', 'Modelo6', 'Modelo7', 'Modelo8'],
    'pirámides': ['Piramide1', 'Piramide2', 'Piramide3', 'Piramide4', 'Piramide5'],
  };

  void uploadToSupabase() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;

    await supabase.from('ar_models').insert({
      'name': nameController.text,
      'description': descController.text,
      'category': selectedCategory,
      'key': selectedKey,
      'riddle': riddleController.text,
      'answer': answerController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Modelo subido')));
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    final keys = selectedCategory != null ? categoryKeys[selectedCategory]! : [];

    return Scaffold(
      appBar: AppBar(title: Text('Administrar Modelos AR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: descController, decoration: InputDecoration(labelText: 'Descripción')),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoría'),
                value: selectedCategory,
                items: categoryKeys.keys.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedKey = null;
                  });
                },
              ),
              if (selectedCategory != null)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Key'),
                  value: selectedKey,
                  items: categoryKeys[selectedCategory]!.map((k) {
                    return DropdownMenuItem(value: k, child: Text(k));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedKey = value),
                ),
              TextFormField(controller: riddleController, decoration: InputDecoration(labelText: 'Adivinanza')),
              TextFormField(controller: answerController, decoration: InputDecoration(labelText: 'Respuesta')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: uploadToSupabase, child: Text('Subir Modelo')),
            ],
          ),
        ),
      ),
    );
  }
}
