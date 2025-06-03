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
  Map<String, dynamic>? editingModel;

  final Map<String, List<String>> categoryKeys = {
    'museo': [
      'Modelo1',
      'Modelo2',
      'Modelo3',
      'Modelo4',
      'Modelo5',
      'Modelo6',
      'Modelo7',
      'Modelo8'
    ],
    'pirámides': [
      'Piramide1',
      'Piramide2',
      'Piramide3',
      'Piramide4',
      'Piramide5'
    ],
  };

  void uploadToSupabase() async {
    if (!_formKey.currentState!.validate()) return;
    final supabase = Supabase.instance.client;

    final data = {
      'name': nameController.text,
      'description': descController.text,
      'category': selectedCategory,
      'key': selectedKey,
      'riddle': riddleController.text,
      'answer': answerController.text,
    };

    if (editingModel != null) {
      await supabase.from('ar_models').update(data).eq('id', editingModel!['id']);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Modelo actualizado')));
    } else {
      await supabase.from('ar_models').insert(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Modelo subido')));
    }

    _formKey.currentState!.reset();
    nameController.clear();
    descController.clear();
    riddleController.clear();
    answerController.clear();
    selectedCategory = null;
    selectedKey = null;
    editingModel = null;
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchModels() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('ar_models').select();
    return List<Map<String, dynamic>>.from(response);
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
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
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
              TextFormField(
                controller: riddleController,
                decoration: InputDecoration(labelText: 'Adivinanza'),
              ),
              TextFormField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Respuesta'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadToSupabase,
                child: Text(editingModel != null ? 'Guardar Cambios' : 'Subir Modelo'),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchModels(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final models = snapshot.data!;
                  return Column(
                    children: models.map((model) {
                      return Card(
                        child: ListTile(
                          title: Text(model['name']),
                          subtitle: Text('Categoría: ${model['category']} | Key: ${model['key']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    editingModel = model;
                                    nameController.text = model['name'];
                                    descController.text = model['description'];
                                    riddleController.text = model['riddle'];
                                    answerController.text = model['answer'];
                                    selectedCategory = model['category'];
                                    selectedKey = model['key'];
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final supabase = Supabase.instance.client;
                                  await supabase
                                      .from('ar_models')
                                      .delete()
                                      .eq('id', model['id']);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
