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
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final int maxLines;

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
    this.validator,
    this.autovalidateMode,
    this.maxLines = 1,
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

  String? _internalValidator(String? value) {
    if (widget.emptyAndSpecialCharValidation) {
      if (value == null || value.trim().isEmpty) {
        return 'Este campo no puede estar vacío.';
      }
      final validText = RegExp("^[a-zA-Z0-9 áéíóúÁÉÍÓÚñÑ.,:;¡!¿?\\-()\"']+\$");
      if (!validText.hasMatch(value.trim())) {
        return 'Solo se permiten letras, números y puntuación básica.';
      }
    }

    if (widget.passwordValidations) {
      if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía.';
      if (value.contains(' ')) return 'La contraseña no puede contener espacios.';
      if (value.length < 8) return 'Debe tener al menos 8 caracteres.';
      if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe tener una mayúscula.';
      if (!value.contains(RegExp(r'[a-z]'))) return 'Debe tener una minúscula.';
      if (!value.contains(RegExp(r'[0-9]'))) return 'Debe tener un número.';
    }

    if (widget.emailValidation) {
      if (value == null || value.trim().isEmpty) return 'El correo no puede estar vacío.';
      final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegExp.hasMatch(value.trim())) return 'Correo electrónico no válido.';
    }

    return null;
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
      maxLines: widget.maxLines,
      validator: (value) {
        final internalError = _internalValidator(value);
        if (internalError != null) return internalError;
        if (widget.validator != null) return widget.validator!(value);
        return null;
      },
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.azulMedio),
        ),
        fillColor: isReadType ? const Color.fromARGB(115, 160, 160, 160) : null,
        filled: isReadType,
        errorText: widget.errorText,
        suffixIcon: widget.passwordView
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: _toggleVisibility,
              )
            : widget.suffixIcon,
      ),
    );
  }
}