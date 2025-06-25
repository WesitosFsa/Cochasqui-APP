
import 'package:cochasqui_park/shared/themes/colors.dart'; 
import 'package:cochasqui_park/shared/widgets/DropdownCamp.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageARadmin extends StatefulWidget {
  const ManageARadmin({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
  String currentView = 'list';
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

  void _resetForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    descController.clear();
    riddleController.clear();
    answerController.clear();
    setState(() {
      selectedCategory = null;
      selectedKey = null;
      editingModel = null;
    });
  }

  void uploadToSupabase() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
      );
      return;
    }

    if (selectedCategory == null || selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría y un modelo.')),
      );
      return;
    }

    final supabase = Supabase.instance.client;

    final data = {
      'name': nameController.text,
      'description': descController.text,
      'category': selectedCategory,
      'key': selectedKey,
      'riddle': riddleController.text,
      'answer': answerController.text,
    };

    try {
      if (editingModel != null) {
        await supabase
            .from('ar_models')
            .update(data)
            .eq('id', editingModel!['id']);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Modelo actualizado exitosamente')));
      } else {
        await supabase.from('ar_models').insert(data);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Modelo subido exitosamente')));
      }

      _resetForm(); 
      setState(() {}); 
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al subir/actualizar modelo: ${e.toString()}')));
    }
  }

  Future<List<Map<String, dynamic>>> fetchModels() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('ar_models').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return []; 
    }
  }

  @override
  Widget build(BuildContext context) {

    final keys = categoryKeys[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Modelos AR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ButtonR(
                    width: 100,
                    icon: Icons.add,
                    text: 'Añadir',
                    onTap: () {
                      _resetForm();
                      setState(() {
                        currentView = 'add';
                      });
                    },
                    color: AppColors.verde,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonR(
                    width: 100,
                    icon: Icons.edit,
                    text: 'Editar',
                    onTap: () {
                      if (editingModel != null) {
                        setState(() {
                          currentView = 'edit';
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Por favor, selecciona un modelo primero desde "Listar" para editar.')),
                        );
                      }
                    },
                    color: AppColors.azulMedio,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonR(
                    width: 100,
                    icon: Icons.view_agenda,
                    text: 'Listar',
                    onTap: () {
                      setState(() {
                        currentView = 'list';
                        _resetForm(); 
                      });
                    },
                    color: AppColors.amarillo,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 20),
            if (currentView == 'add' || currentView == 'edit')
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      TextCamp(
                        label: 'Nombre',
                        controller: nameController,
                        emptyAndSpecialCharValidation: true,
                      ),
                      const SizedBox(height: 10),
                      TextCamp(
                        label: 'Descripción',
                        controller: descController,
                        emptyAndSpecialCharValidation: true,
                        maxLines: 5, 
                        keyboardType: TextInputType.multiline, 
                      ),
                      const SizedBox(height: 10),
                      DropdownCamp(
                        label: 'Categoría',
                        value: selectedCategory,
                        items: categoryKeys.keys.toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectedKey =
                                null; 
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      if (selectedCategory != null)
                        DropdownCamp(
                          label: 'Modelo',
                          value: selectedKey,
                          items: keys, 
                          onChanged: (value) =>
                              setState(() => selectedKey = value),
                        ),
                      const SizedBox(height: 10),
                      TextCamp(
                        label: 'Adivinanza',
                        controller: riddleController,
                        emptyAndSpecialCharValidation: true,
                      ),
                      const SizedBox(height: 10),
                      TextCamp(
                        label: 'Respuesta',
                        controller: answerController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo no puede estar vacío.';
                          }
                          final validText = RegExp(r"^[\p{L}\p{N}\p{P}\p{S}\s]+$", unicode: true);
                          if (!validText.hasMatch(value.trim())) {
                            return 'Algunos caracteres no están permitidos.'; 
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ButtonR(
                        icon: Icons.save,
                        onTap: uploadToSupabase,
                        text: editingModel != null
                            ? 'Guardar Cambios'
                            : 'Subir Modelo',
                        color: AppColors.azulOscuro,
                      ),
                    ],
                  ),
                ),
              ),
            if (currentView == 'list')
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchModels(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.azulMedio)); 
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No hay modelos para mostrar.',
                              style: TextStyle(color: Colors.black54))); 
                    }
                    final models = snapshot.data!;
                    return ListView.builder(
                      itemCount: models.length,
                      itemBuilder: (context, index) {
                        final model = models[index];
                        return Card(
                          color: AppColors.celesteClaro, 
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 0),
                          child: ListTile(
                            title: Text(model['name'] ?? 'Sin Nombre',
                                style: const TextStyle(color: AppColors.azulOscuro, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Categoría: ${model['category'] ?? 'N/A'} | Modelo: ${model['key'] ?? 'N/A'}',
                                style: const TextStyle(color: AppColors.azulGris)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.azulMedio), 
                                  onPressed: () {
                                    setState(() {
                                      editingModel = model;
                                      nameController.text = model['name'] ?? '';
                                      descController.text =
                                          model['description'] ?? '';
                                      riddleController.text = model['riddle'] ?? '';
                                      answerController.text = model['answer'] ?? '';
                                      selectedCategory = model['category'];
                                      selectedKey = model['key'];
                                      currentView = 'edit';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: AppColors.rojo), 
                                  onPressed: () async {
                                    final supabase = Supabase.instance.client;
                                    try {
                                      await supabase
                                          .from('ar_models')
                                          .delete()
                                          .eq('id', model['id']);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Modelo eliminado exitosamente')));
                                      setState(
                                          () {}); 
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Error al eliminar: ${e.toString()}')));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}