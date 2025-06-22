import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:flutter/material.dart';

class TextCamp extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool passwordView;
  final bool readType;
  final bool passwordValidations;
  final bool emptyAndSpecialCharValidation;
  final bool emailValidation;
  final TextInputType? keyboardType;
  // Añade estos dos nuevos parámetros
  final String? Function(String?)? validator; // Permite pasar un validador externo
  final AutovalidateMode? autovalidateMode; // Permite controlar el modo de autovalidación

  const TextCamp({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.onTap,
    this.onSubmitted,
    this.errorText,
    this.passwordView = false,
    this.readType = false,
    this.passwordValidations = false,
    this.emptyAndSpecialCharValidation = false,
    this.emailValidation = false,
    this.keyboardType,
    this.validator, // Inicializa el nuevo parámetro
    this.autovalidateMode, // Inicializa el nuevo parámetro
  });

  @override
  State<TextCamp> createState() => _TextCampState();
}

class _TextCampState extends State<TextCamp> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  // Este es el validador interno de TextCamp
  String? _internalValidator(String? value) {
    if (widget.emptyAndSpecialCharValidation) {
      if (value == null || value.trim().isEmpty) {
        return 'Este campo no puede estar vacío.';
      }
      final nameRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
      if (!nameRegExp.hasMatch(value.trim())) {
        return 'Solo se permiten letras y espacios.';
      }
    }

    if (widget.passwordValidations) {
      if (value == null || value.isEmpty) {
        return 'La contraseña no puede estar vacía.';
      }
      // Nueva validación: no permitir espacios en blanco
      if (value.contains(' ')) {
        return 'La contraseña no puede contener espacios en blanco.';
      }
      if (value.length < 8) {
        return 'La contraseña debe tener al menos 8 caracteres.';
      }
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'La contraseña debe contener al menos una mayúscula.';
      }
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'La contraseña debe contener al menos una minúscula.';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'La contraseña debe contener al menos un número.';
      }
    }

    if (widget.emailValidation) {
      if (value == null || value.trim().isEmpty) {
        return 'El campo de correo electrónico no puede estar vacío.';
      }
      final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegExp.hasMatch(value.trim())) {
        return 'Por favor, introduce un correo electrónico válido.';
      }
    }

    return null; // Retorna null si todas las validaciones internas son exitosas
  }


  @override
  Widget build(BuildContext context) {
    final bool isReadType = widget.readType;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      cursorColor: isReadType ? Colors.white : Colors.black,
      keyboardType: widget.keyboardType,
      // Combina el validador interno con el validador externo si se proporciona
      validator: (value) {
        final internalError = _internalValidator(value);
        if (internalError != null) {
          return internalError;
        }
        // Si no hay error interno, llama al validador externo si existe
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction, // Pasa el autovalidateMode
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.azulMedio),
        ),
        fillColor: isReadType ? const Color.fromARGB(115, 160, 160, 160) : null,
        filled: isReadType,
        errorText: widget.errorText, // Todavía permitimos errorText directo para otros casos
        suffixIcon: widget.passwordView
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: _toggleVisibility,
              )
            : widget.suffixIcon,
      ),
    );
  }
}