import 'package:flutter/material.dart';

class TextCamp extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;

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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
