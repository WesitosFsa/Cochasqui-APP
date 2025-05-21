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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
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
