import 'package:cochasqui_park/core/supabase/auth_service.dart';
import 'package:cochasqui_park/features/auth/widgets/buttonR.dart';
import 'package:cochasqui_park/features/auth/widgets/textcamp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  int currentStep = 0;
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final fechaNacimientoController = TextEditingController(); // Nuevo controlador para la fecha
  String? genero;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool aceptoTerminos = false;

  List<Widget> pasosRegistro(BuildContext context) => [
    _buildNombreApellido(),
    _buildFechaNacimiento(context),
    _buildGenero(),
    _buildEmailPassword(),
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

  Widget _buildEmailPassword() {
    return Column(
      children: [
        TextCamp(label: 'Correo', controller: emailController),
        SizedBox(height: 16),
        TextCamp(label: 'Contraseña', controller: passwordController,obscureText: true,),
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
      // mostrar error
      return;
    }

    // Convertir la fecha de texto a DateTime
    final fechaParts = fechaNacimientoController.text.split('/');
    final fechaNacimiento = DateTime(
      int.parse(fechaParts[2]),
      int.parse(fechaParts[1]),
      int.parse(fechaParts[0]),
    );

    final res = await AuthService().signUp(emailController.text, passwordController.text);
    final userId = res.user?.id;

    if (userId != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'nombre': nombreController.text,
        'apellido': apellidoController.text,
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'genero': genero,
      });

      // Redirigir a home o donde quieras
    }
  }
}