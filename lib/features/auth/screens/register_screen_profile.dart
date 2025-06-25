// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore
import 'package:cochasqui_park/features/auth/screens/login_screen.dart';
import 'package:cochasqui_park/shared/widgets/DropdownCamp.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:cochasqui_park/shared/widgets/text_camp.dart'; 
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
  final fechaNacimientoController = TextEditingController();
  String? genero;
  bool aceptoTerminos = false;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  final _formKeyStep4 = GlobalKey<FormState>();

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    fechaNacimientoController.dispose();
    super.dispose();
  }

  List<Widget> pasosRegistro(BuildContext context) => [
        _buildNombreApellido(),
        _buildFechaNacimiento(context),
        _buildGenero(),
        _buildTerminos(),
      ];

  Widget _buildNombreApellido() {
    return Form(
      key: _formKeyStep1, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextCamp(
            label: 'Nombre',
            controller: nombreController,
            emptyAndSpecialCharValidation: true, 
            keyboardType: TextInputType.text, 
            autovalidateMode: AutovalidateMode.onUserInteraction, 
          ),
          const SizedBox(height: 16),
          TextCamp(
            label: 'Apellido',
            controller: apellidoController,
            emptyAndSpecialCharValidation: true, 
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction, 
          ),
        ],
      ),
    );
  }

  Widget _buildFechaNacimiento(BuildContext context) {
    return Form(
      key: _formKeyStep2, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextCamp(
            label: 'Fecha de Nacimiento',
            controller: fechaNacimientoController,
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000), 
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                locale: const Locale('es', 'ES'), 
              );
              if (picked != null) {
                setState(() {
                  fechaNacimientoController.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                });
              }
              _formKeyStep2.currentState?.validate();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecciona tu fecha de nacimiento.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenero() {
    return Form(
      key: _formKeyStep3, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Selecciona tu género', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownCamp(
            label: 'Género',
            value: genero,
            items: const ['Masculino', 'Femenino', 'Otro'],
            onChanged: (value) {
              setState(() {
                genero = value;
              });
              _formKeyStep3.currentState?.validate(); 
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecciona tu género.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTerminos() {
    return Form(
      key: _formKeyStep4, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            title: const Text("Acepto términos y condiciones"),
            value: aceptoTerminos,
            onChanged: (val) {
              setState(() {
                aceptoTerminos = val ?? false;
              });
              _formKeyStep4.currentState?.validate(); 
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (!aceptoTerminos && _formKeyStep4.currentState?.validate() == false)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Debes aceptar los términos y condiciones para continuar.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return _formKeyStep1.currentState!.validate();
      case 1:
        return _formKeyStep2.currentState!.validate();
      case 2:
        return _formKeyStep3.currentState!.validate();
      case 3:

        return aceptoTerminos; 
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBE9),
      appBar: AppBar(
        title: const Text('Registro de Perfil'),
        backgroundColor: Colors.blueAccent,
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    currentStep--;
                  });
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                      if (_validateCurrentStep()) {
                        if (currentStep < pasosRegistro(context).length - 1) {
                          setState(() {
                            currentStep++;
                          });
                        } else {
                          _registrarse();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, corrige los errores antes de continuar.')),
                        );
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
        const SnackBar(content: Text('Debes aceptar los términos y condiciones para completar el registro.')),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID del usuario. Por favor, intente iniciar sesión de nuevo.')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    DateTime fechaNacimiento;
    try {
      final fechaParts = fechaNacimientoController.text.split('/');
      fechaNacimiento = DateTime(
        int.parse(fechaParts[2]),
        int.parse(fechaParts[1]),
        int.parse(fechaParts[0]),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en el formato de la fecha de nacimiento. Por favor, selecciona una fecha válida.')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'nombre': nombreController.text.trim(),
        'apellido': apellidoController.text.trim(),
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'genero': genero,
        'rol': 'usuario', 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Registro completado correctamente. Por favor, inicia sesión para disfrutar de la experiencia.')),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el perfil: ${e.toString()}')),
      );
    }
  }
}