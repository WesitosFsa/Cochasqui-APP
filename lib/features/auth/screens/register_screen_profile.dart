import 'package:cochasqui_park/features/auth/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/textcamp.dart';
import 'package:cochasqui_park/features/main/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreenProfile extends StatefulWidget {
  const RegisterScreenProfile({super.key});
  @override
  State<RegisterScreenProfile> createState() => _RegisterScreenProfile();
}
class _RegisterScreenProfile extends State<RegisterScreenProfile> {
  int currentStep = 0;
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final fechaNacimientoController = TextEditingController(); // Nuevo controlador para la fecha
  String? genero;
  bool aceptoTerminos = false;
  List<Widget> pasosRegistro(BuildContext context) => [
    _buildNombreApellido(),
    _buildFechaNacimiento(context),
    _buildGenero(),
    _buildTerminos(),
  ];
  Widget _buildNombreApellido() {
    return Column(
      children: [
        TextCamp(label: 'Nombre', controller: nombreController),
        SizedBox(height: 16),
        TextCamp(label: 'Apellido', controller: apellidoController),
      ],
    );
  }
  Widget _buildFechaNacimiento(BuildContext context) {
    return Column(
      children: [
        TextCamp(
          label: 'Fecha de Nacimiento',
          controller: fechaNacimientoController,
          readOnly: true, 
          suffixIcon: Icon(Icons.calendar_today), // Hace que el campo sea de solo lectura
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                // Formatear la fecha como quieras mostrarla
                fechaNacimientoController.text = "${picked.day}/${picked.month}/${picked.year}";
              });
            }
          },
        ),
      ],
    );
  }
  Widget _buildGenero() {
    return Column(
      children: [
        Text('Selecciona tu género'),
        DropdownButton<String>(
          value: genero,
          items: ['Masculino', 'Femenino', 'Otro']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (value) {
            setState(() {
              genero = value;
            });
          },
        ),
      ],
    );
  }
  Widget _buildTerminos() {
    return CheckboxListTile(
      title: Text("Acepto términos y condiciones"),
      value: aceptoTerminos,
      onChanged: (val) {
        setState(() {
          aceptoTerminos = val ?? false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEBE9),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          children: [
            const SizedBox(height: 50),
            Expanded(
              child: pasosRegistro(context)[currentStep],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonR(
                    text: 'Atrás',
                    showIcon: false,
                    onTap: currentStep > 0
                        ? () {
                            setState(() {
                              currentStep--;
                            });
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ButtonR(
                    text: currentStep == pasosRegistro(context).length - 1
                        ? 'Registrarse'
                        : 'Siguiente',
                    showIcon: false,
                    onTap: () {
                      if (currentStep < pasosRegistro(context).length - 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        _registrarse();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _registrarse() async {
  if (!aceptoTerminos) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Debes aceptar los términos y condiciones')),
    );
    return;
  }

  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: No se encontró el usuario')),
    );
    return;
  }

  // Convertir fecha:
  final fechaParts = fechaNacimientoController.text.split('/');
  final fechaNacimiento = DateTime(
    int.parse(fechaParts[2]),
    int.parse(fechaParts[1]),
    int.parse(fechaParts[0]),
  );
  if (nombreController.text.isEmpty || 
      apellidoController.text.isEmpty ||
      fechaNacimientoController.text.isEmpty ||
      genero == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, completa todos los campos')),
    );
    return;
  }


  await Supabase.instance.client.from('profiles').insert({
    'id': userId,
    'nombre': nombreController.text,
    'apellido': apellidoController.text,
    'fecha_nacimiento': fechaNacimiento.toIso8601String(),
    'genero': genero,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Perfil registrado correctamente')),
  );

  await Future.delayed(Duration(seconds: 2)); // opcional

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));

  }

}